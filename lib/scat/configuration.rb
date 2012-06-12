require 'yaml'
require 'jinx/helpers/hash'
require 'scat/field'

module Scat
  # The Scat Configuration specifies the edit form fields. 
  class Configuration
    # @param [String] the configuration file path
    def initialize(file)
      @fld_hash = parse(YAML.load_file(file))
      logger.debug { "Scat fields: #{@fld_hash.transform_value { |f| f.members.to_compact_hash { |a| f[a] } }.qp}" }
    end
    
    # @return [<#name, #label, #help, #properties>] the specimen edit field specifications
    def fields
      @fld_hash.values
    end

    # @param [{String => String}] params the request parameters
    # @return [{Class => {CaRuby::Property => Object}}] the caTissue class => { property => value } hash
    def slice(params)
      validate(params)
      hash = Jinx::LazyHash.new { Hash.new }
      params.each do |name, value|
        next if value.nil?
        # Skip the param if it is not obtained from the request.
        field = @fld_hash[name.to_sym] || next
        field.properties.each do |klass, prop|
          # Convert non-string values.
          if prop.type <= Integer or prop.type <= Java::JavaLang::Integer then
            value = value.to_i
          elsif prop.type <= Date or prop.type <= Java::JavaUtil::Date then
            value = DateTime.parse(value)
          elsif prop.type <= Numeric or prop.type <= Java::JavaLang::Number then
            value = value.to_f
          end
          # Generalize a Specimen subclass.
          klass = CaTissue::Specimen if klass < CaTissue::Specimen
          # Add the property value.
          hash[klass][prop.to_sym] = value
        end
      end
      hash
    end    
    
    private
    
    # Parses the field configuration as follows:
    # * The form attributes are described in {#form_attributes}.
    # * The properties are a (_class_, _property_) tuple specified by the
    #   comma-delimited configuration +property+ array.
    # * The optional help text is the text which follows the property list.
    #                      
    # @param [{String => String}] config the field label => spec hash
    # @return [{Symbol} => Field] the symbol => Field hash
    def parse(file)
      hash = {}
      file.each do |label, spec|
        field = Field.new
        field.name = label.gsub(' ', '_').gsub(/[^\w]/, '').downcase.to_sym
        field.label = label
        # Parse the property list.
        field.properties = spec['properties'].delete(' ').split(',').map do |pspec|
          klass_s, attr_s = pspec.split('.')
          begin
            klass = CaTissue.module_with_name(klass_s)
            [klass, klass.property(attr_s.to_sym)]
          rescue
            raise ScatError.new("Scat configuration field not recognized: #{pspec} - " + $!)
          end
        end
        field.type = spec['type']
        field.type ||= label[-1, 1] == '?' ? 'checkbox' : 'text'
        if field.type == 'checkbox' then
          field.value = spec['value']
          field.value ||= label[-1, 1] == '?' ? label[0...-1] : label
        end
        field.help = spec['help']
        field.default = spec['default']
        # Add the parsed field.
        hash[field.name] = field
      end
      hash
    end
    
    # @param (see #save)
    # @return [String, nil] the validation error message, if any
    def validate(params)
      missing = params.map { |name, value| @fld_hash[name.to_sym].label if value.blank? }.compact
      unless missing.empty? then
        raise ScatError.new("Scat is missing the input fields #{missing.to_series}")
      end
    end
  end
end
 