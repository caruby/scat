require 'jinx/helpers/inflector'
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
    # @return [String] the JSON representation of the matching values
    def autocomplete(attribute, text)
      # Start up the cache if necessary
      @cache ||= Cache.new
      # Compare lower case.
      text_dc = text.downcase
      # The search term is the first word in the text.
      words = text_dc.split(' ')
      term = words.first
      logger.debug { "Scat is matching the cached #{attribute} values which contain #{term}..." }
      # The hash key, e.g. dx:lymphoma.
      key = KEY_PREFIX_HASH[attribute] + term
      # The CVs which match the term.
      cvs = @cache.get_all(key)
      # Load the CVs if necessary.
      cvs = load_controlled_values(attribute, term, key) if cvs.empty?
      # The CVs which match the entire target.
      matched = words.size == 1 ? cvs : cvs.select { |cv| cv.downcase[text_dc] }
      logger.debug { "#{matched.empty? ? 'No' : matched.size} #{attribute} values match '#{text}'." }
      matched.to_json
    end
    
    private
    
    KEY_PREFIX_HASH = {
       :clinical_diagnosis => 'dx:',
       :tissue_site => 'ts:'
    }
    
    # The template to fetch CVs matching a PID and key term.
    # The SQL cheats a little, since it theoretically could return a CV with null PID
    # whose parentage is not directly or indirectly in the PID. However, this problem
    # does not occur in practice and is relatively benign if it should occur, since at
    # worst it includes a few obviously extraneous matches.
    CV_TMPL = "select value
      from catissue_permissible_value pv
      where (public_id = '%s' or (public_id is null and parent_identifier is not null))
      and value like '%%%s%%'
      and not exists (select 1 from catissue_permissible_value where parent_identifier = pv.identifier)"
    
    # @param (see #match)
    # @param [Strimg] the cache key
    # @return (see #match)
    def load_controlled_values(attribute, term, key)
      logger.debug { "Scat is loading the #{attribute} controlled values which match '#{term}'..." }
      # The CV PID, e.g. the :tissue_site PID is Tissue_Site_PID.
      pid = attribute.to_s.split('_').map { |s| s.capitalize_first }.join('_') << '_PID'
      # The SQL is the template formatted with the PID and term.
      sql = CV_TMPL % [pid, term]
      # Cache each fetched CV.
      cvs = CaTissue::Database.current.executor.query(sql).map do |rec|
        cv = rec.first
        @cache.add(key, cv)
        cv
      end
      logger.debug { "Scat loaded #{cvs.size} #{attribute} #{term} controlled values." }
      cvs
    end
  end
end
