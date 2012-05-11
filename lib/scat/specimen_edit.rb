require 'singleton'
require 'jinx/helpers/validation'
require 'scat/authorization'
require 'scat/cache'

module Scat
  # The SpecimenEdit makes a +CaTissue::Specimen+ from the specimen edit form parameters
  # and creates the specimen in the database.
  class SpecimenEdit
    include Singleton
    
    # The specimen field => label hash. A colon is appended to each label
    # to make the specimen edit page HTML form label.
    FIELDS = {
      :protocol => 'Protocol',
      :mrn => 'MRN',
      :spn => 'SPN',
      :diagnosis => 'Diagnosis',
      :tissue_site => 'Tissue Site',
      :quantity => 'Quantity'
    }
    
    # Saves the +CaTissue::Specimen+ object specified in the request parameters.
    #
    # @param [{Symbol => String}] params the request parameters
    # @return [String] the save status message
    # @raise [ArgumentError] if the parameters do not include a +:protocol+
    # @raise [CaTissue::DatabaseError] if the save is unsuccessful
    def save(params)
      validate(params)
      pcl = CaTissue::CollectionProtocol.new(:title => params[:protocol])
      raise ArgumentError.new("Protocol not found: #{pcl.title}") unless pcl.find
      cpe = pcl.events.first
      pnt = CaTissue::Participant.new(:last_name => params[:mrn])
      user = params[:user]
      site = user.find.sites.first || CaTissue::Site.default_site
      mrn = CaTissue::ParticipantMedicalIdentifier.new(:participant => pnt, :site => site, :medical_record_number => params[:mrn])
      reg = pcl.register(pnt)
      rqmt = cpe.requirements.first
      spc = CaTissue::Specimen.create_specimen(:requirement => rqmt, :initial_quantity => params[:quantity].to_f)
      scg = pcl.add_specimens(spc, :participant => pnt, :surgical_pathology_number => params[:spn],
        :collection_event => cpe, :collector => user)
      logger.debug { "Scat is saving the following specimen:\n#{spc.dump}" }
      spc.save
      "Saved the patient #{mrn} specimen with label #{spc.label}."
    end

    private
    
    # @param (see #save)
    # @return [String, nil] the validation error message, if any
    def validate(params)
      missing = FIELDS.map { |k, v| v unless params[k] }.compact
      unless missing.empty? then
        raise Jinx::ValidationError.new("Missing #{missing.to_series}")
      end
    end
  end
end
      