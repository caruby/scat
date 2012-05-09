require Bundler.environment.specs.detect { |s| s.name == 'caruby-tissue' }.full_gem_path + '/examples/galena/lib/galena/seed'

module Scat
  # The Scat test protocol fixture.
  module ProtocolFactory
    # @param [String] title the protocol title
    # @return [CaTissue::CollectionProtocol] a new protocol with one event and one frozen tissue requirement
    def self.create_protocol(title)
      # Borrow the Galena seed.
      galena = Galena.administrative_objects
      
      # Make a new Scat CP.
      @protocol = CaTissue::CollectionProtocol.new(
        :title => title, 
        :principal_investigator => galena.protocol.principal_investigator,
        :sites => [galena.tissue_bank]
      )

      # CPE has default 1.0 event point and label
      cpe = CaTissue::CollectionProtocolEvent.new(:collection_protocol => @protocol, :event_point => 1.0)
      
      # The sole specimen requirement. Setting the requirement collection_event attribute to a CPE automatically
      # sets the CPE requirement inverse attribute in caRuby.
      CaTissue::TissueSpecimenRequirement.new(:collection_event => cpe, :specimen_type => 'Frozen Tissue')
    end
  end
end
    