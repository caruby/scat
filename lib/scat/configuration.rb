require 'yaml'
require 'jinx/helpers/hash'
require 'scat/field'

module Scat
  # The Scat Configuration specifies the edit form fields. 
  class Configuration
    # @param [String] the configuration file path
    def initialize(file)
      # the field name => Field hash
      @fld_hash = parse(YAML.load_file(file))
      logger.info("Scat fields: #{@fld_hash.values.pp_s}")
    end
    
    # @param [Symbol, String] name the field name or label           
    # @return [Field] the corresponding field
    def [](name_or_label)
      # the standardized field name
      key = case name_or_label
      when Symbol then
        name_or_label
      when String then
        Field.name_for(name_or_label).to_sym
      else
        raise ArgumentError.new("Scat field argument not supported: #{name_or_label.qp}")
      end
      @fld_hash[key]
    end
    
    # Returns the edit form field specifications.
    #
    # @return [<Field>] the specimen edit field specifications
    def fields
      @fld_hash.values
    end

    # @param [{String => String}] params the request parameters
    # @return [{Class => {CaRuby::Property => Object}}] the caTissue class => { property => value } hash
    def slice(params)
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
    
    # Parses the field configuration as described in {Field}.
    #                      
    # @param [{String => String}] config the field label => spec hash
    # @return [{Symbol} => Field] the symbol => Field hash
    def parse(config)
      hash = {}
      config.each do |label, spec|
        field = Field.new(label, spec)
        hash[field.name.to_sym] = field
      end
      hash
    end
  end
end
 