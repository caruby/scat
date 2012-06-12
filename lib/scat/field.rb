module Scat
  # The form field data structure.
  Field = Struct.new(:name, :label, :properties, :help, :type, :value, :default)
  class Field
    # Returns this field's HTML input element attributes. The attributes are determined
    # by the field configuration as follows:
    # * +:type+: this field's type
    # * :value: this field's value if the field type is +checkbox+, otherwise unset.
    # * A type element name is the lower-case label with spaces replaced by an
    # * :checked: +true+ if the field type is +checkbox+ and the field default is set.
    # * :name: if the field type is not +checkbox+,
    #   underscore and any other special characters removed, e.g. an element with label
    #   +Tissue Site+ has name +tissue_site+.
    # * A checkbox element has a +checked+ attribute if the field configuration is
    #   neither nil nor false.
    #
    # @return [{Symbol => String}] the form input element attributes
    def form_attributes
      params = {:type => type }
      if type == 'checkbox' then
        params[:value] = value
        params[:checked] = true if default
      else
        # Make the underscore field name from the label. 
        params[:name] = name
      end  
      params
    end
  end
end
