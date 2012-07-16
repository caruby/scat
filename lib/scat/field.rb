module Scat
  class Field
    # The underscore label with any other special characters removed,
    # converted to a symbol. For example, an element with label +Tissue Site+
    # has name +:tissue_site+.
    attr_reader :name

    # The +checkbox+ or +text+ element type.
    attr_reader :type
    
    # The element label attribute.
    attr_reader :label
    
    # The HTML input element id.
    attr_reader :input_id
    
    # The (class, +Jinx::Property+) tuples which determine which property is
    # set by the input value.
    attr_reader :properties

    # The optional help text displayed in a web hover pop-up.
    attr_reader :help
    
    # This field's value if the field type is +checkbox+, otherwise nil.
    attr_reader :value

    # If the field type is +checkbox+, then this flag determines whether
    # the box is initially checked.
    attr_reader :default
    
    # @param [String] label the field label
    # @param [Symbol] name the field name
    def self.name_for(label)
      name = label.gsub(' ', '_').gsub(/[^\w]/, '').downcase
      # Strip the trailing ?, if any.
      name[-1, 1] == '?' ? name[0...-1] : name
    end
    
    # Parses the given field specification.
    #
    # @param [String] label the configuration field specification key
    # @param [{String => String}] spec the configuration field specification value
    def initialize(label, spec)
      @name = Field.name_for(label)
      @input_id = @name + '_input'
      @label = label
      # Parse the property list.
      @properties = spec['properties'].delete(' ').split(',').map do |pspec|
        klass_s, attr_s = pspec.split('.')
        begin
          klass = CaTissue.module_with_name(klass_s)
          [klass, klass.property(attr_s.to_sym)]
        rescue
          raise ScatError.new("Scat configuration field not recognized: #{pspec} - " + $!)
        end
      end
      @type = spec['type']
      # The default type is checkbox if the label ends in ?, text otherwise.
      @type ||= label[-1, 1] == '?' ? 'checkbox' : 'text'
      # A checkbox has a value.
      if @type == 'checkbox' then
        @value = spec['value']
        @value ||= label[-1, 1] == '?' ? label[0...-1] : label
      end
      @help = spec['help']
      @default = spec['default']
    end
    
    # Returns this field's HTML input element attributes and target caTissue properties.
    #
    # The attributes are determined by the field configuration as follows:
    # * +id+: this field's HTML input element id
    # * +type+: this field's type
    # * +checked+: +true+ if the field type is +checkbox+ and the field default is set
    # * +name+: if the field type is not +checkbox+, then this field's name
    #
    # @param [String, nil] value the request parameter value
    # @return [{Symbol => String}] the form input element attributes
    def input_attributes(value)
      params = {:id => input_id, :type => type, :name => name, :value => value }
      if type == 'checkbox' then
        params[:value] ||= self.value
        params[:checked] = true if default
      end
      params
    end

    # @param q the PrettyPrint queue 
    # @return [String] the formatted content of this field
    def pretty_print(q)
      q.text(name)
      avh = [:label, :type, :help, :value, :default].to_compact_hash { |a| send(a) }
      avh[:properties] = properties.map { |k, p| [k.name.demodulize, p.to_s].join('.') } 
      q.pp_hash(avh)
    end
    
    alias :to_s :name
  end
end
