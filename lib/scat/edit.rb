require 'singleton'
require 'jinx/helpers/validation'
require 'scat/configuration'
require 'scat/authorization'
require 'scat/cache'

module Scat
  # The Edit helper makes a +CaTissue::Specimen+ from the edit form parameters and creates
  # the specimen in the database.
  class Edit
    include Singleton
    
    def initialize
      super
      @conf = Configuration.new(FIELD_CONFIG)
    end
    
    # @return (see Config#fields)
    def fields
      # Delegate to the configuration.
      @conf.fields
    end
    
    # Saves the +CaTissue::Specimen+ object specified in the request parameters.
    #
    # @param [{Symbol => String}] params the request parameters
    # @return [CaTissue::Specimen] the saved specimen
    # @raise [ScatError] if the parameters are insufficient to build a specimen
    # @raise [CaRuby::DatabaseError] if the save is unsuccessful
    def save(params)
      logger.debug { "Scat is saving the specimen with parameters #{params.qp}..." }
      # the caTissue class => { property => value } hash
      ph = @conf.slice(params)
      # the collection protocol
      pcl = to_protocol(ph[CaTissue::CollectionProtocol])
      # the current user
      user = params[:user]
      # the collection site
      site = to_site(pcl, user)
      # the patient
      pnt = CaTissue::Participant.new(ph[CaTissue::Participant])
      # the CPR parameters
      reg_params = ph[CaTissue::ParticipantMedicalIdentifier].merge(:participant => pnt, :site => site)
      # the CPR
      reg = to_registration(pcl, reg_params)
      # the specimen parameters
      spc_params = ph[CaTissue::Specimen].merge(ph[CaTissue::SpecimenCharacteristics])
      # The current user is the biobank specimen receiver.
      spc_params.merge!(:receiver => user)
      # the specimen to save
      spc = to_specimen(pcl, spc_params)
      # the SCG parameters
      scg_params = ph[CaTissue::SpecimenCollectionGroup].merge(:participant => pnt, :site => site)
      # the SCG which contains the specimen
      pcl.add_specimens(spc, scg_params)
      # Save the specimen.
      logger.debug { "Scat is saving #{spc} with content:\n#{spc.dump}" }
      spc.save
      logger.debug { "Scat saved #{spc}." }
      spc
    end

    private
      
    # The field configuration file name.
    FIELD_CONFIG = File.dirname(__FILE__) + '/../../conf/fields.yaml'
    
    # Builds the registration object specified in the given parameters.
    #
    # @param [{Symbol => String}] params the registration parameters
    # @return [CaTissue::CollectionProtocolRegistration] the SCG to save
    def to_protocol(params)
      pcl = CaTissue::CollectionProtocol.new(params)
      pcl.find or raise ScatError.new("Protocol not found: #{pcl.title}")
    end
    
    # The collection site is the first match for the following criteria:
    # * the first site of the current user
    # * the first protocol site
    # * the first protocol coordinator site
    #              
    # @param [CaTissue::CollectionProtocol] protocol the collection protocol
    # @param [CaTissue::User] user the current user
    # @return [CaTissue::Site] the collection site 
    def to_site(protocol, user)
      user.find unless user.fetched?
      site = user.sites.first
      return site if site
      protocol.find unless protocol.fetched?
      site = protocol.sites.first
      return site if site
      site = protocol.coordinators.detect_value { |coord| coord.sites.first } or
        raise ScatError.new("Neither the user #{rcvr.email_address} nor the #{pcl.title} protocol administrators have an associated site.")
    end
    
    # Builds the registration object specified in the given parameters.
    #
    # @param [CaTissue::CollectionProtocol] protocol the collection protocol
    # @param [{Symbol => String}] params the registration parameters
    # @return [CaTissue::CollectionProtocolRegistration] the SCG to save
    def to_registration(protocol, params)
      # If there is an MRN, then make a PMI
      if params.has_key?(:medical_record_number) then
        CaTissue::ParticipantMedicalIdentifier.new(params)
      end
      # the patient
      pnt = params[:participant]
      # Register the patient.
      protocol.register(pnt)
    end
    
    # Builds the +CaTissue::Specimen+ object specified in the given parameters.
    #
    # The default edit form pathological status checkbox value is 'Malignant'.
    # If the user unchecked it, then there is no pathological status parameter.
    # In that case, the pathological status is 'Non-Malignant'. 
    #
    # @param [CaTissue::CollectionProtocol] protocol the collection protocol
    # @param [{Symbol => String}] params the Specimen parameters
    # @return [CaTissue::Specimen] the specimen to save
    def to_specimen(protocol, params)
      params[:pathological_status] ||= 'Non-Malignant'
      # The CPE is the sole protocol event.
      cpe = protocol.events.first
      # The specimen requirement is the sole event requirement.
      rqmt = cpe.requirements.first
      # Make the specimen.
      CaTissue::Specimen.create_specimen(params.merge(:requirement => rqmt))
    end
  end
end
      