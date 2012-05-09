require 'catissue/database/controlled_values'
require 'scat/cache'

module Scat
  # Auto-completion mix-in.
  module Autocomplete
    # Fetches controlled caTissue values for the given attribute and value prefix.
    # The supported attributes include the following:
    # * +:clinical_diagnosis+ (+SpecimenCollectionGroup.clinical_diagnosis+)
    # * +:tissue_site+ (+SpecimenCharacteristics.tissue_site+)
    #
    # @param [Symbol] attribute the CV attribute
    # @param [String] prefix the leading value letters
    # @return [<String>] the matching values
    def autocomplete(attribute, text)
      # Start up the cache if necessary
      @cache ||= Cache.new
      # the match target string
      tgt = text.downcase
      # the first target word
      word = tgt[/^\w+/]
      # Load the CVs if necessary.
      load_controlled_values(attribute) unless @cache.get(attribute)
      # the CVs which matching the first word
      cvs = @cache.get_all("#{attribute}:#{word}") || return
      # the CVs which match the entire target
      cvs.select { |cv| cv.downcase[tgt] }
    end
    
    private
    
    DIAGNOSES_STMT = "select value from catissue_permissible_value where public_id = 'Clinical_Diagnosis_PID'"
    
    def load_controlled_values(attribute)
      logger.debug { "Scat is loading the #{attribute} controlled values..." }
      cnt = case attribute
      when :clinical_diagnosis then
        load_diagnoses
      when :tissue_site then
        load_tissue_sites
      else
        load_terminal_controlled_values(attribute)
      end
      logger.debug { "Scat loaded #{cnt} #{attribute} controlled values into the cache." }
      @cache.set(attribute, true)
    end
    
    def load_diagnoses
      cnt = 0
      CaTissue::Database.current.executor.query(DIAGNOSES_STMT) do |rec|
        cv = rec.first
        cv.downcase.scan(/\w+/).each do |word|
          if word.length > 4 then
            @cache.add("clinical_diagnosis:#{word}", cv)
          end
        end
        cnt += 1
      end
      cnt
    end
    
    def load_terminal_controlled_values(attribute)
      cnt = 0
      cvs = CaTissue::ControlledValues.instance.for_public_id(attribute)
      cvs.each do |cv|
        next if cv.parent
        val = cv.value
        val.downcase.scan(/\w+/).each do |word|
          if word.length > 4 then
            @cache.add("#{attribute}:#{word}", val)
          end
        end
        cnt += 1
      end
      CaTissue::ControlledValues.instance.clear
      cnt
    end
  end
end
