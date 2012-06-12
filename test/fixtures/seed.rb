require Bundler.environment.specs.detect { |s| s.name == 'caruby-tissue' }.full_gem_path + '/examples/galena/lib/galena/seed'

module Scat
  # The Scat test protocol fixture.
  module Seed
    # @param [String] title the protocol title
    # @return [CaTissue::CollectionProtocol] a new test protocol with one event and one frozen tissue requirement
    def self.protocol_for(title)
      # Borrow the Galena seed.
      galena = Galena.administrative_objects
      # the CP
      pcl = CaTissue::CollectionProtocol.new(
        :title => title, 
        :principal_investigator => galena.protocol.principal_investigator,
        :sites => [galena.tissue_bank],
        :coordinators => [galena.tissue_bank.coordinator]
      )
      # the sole event
      cpe = CaTissue::CollectionProtocolEvent.new(:collection_protocol => pcl, :event_point => 1.0)
      # the sole specimen requirement
      CaTissue::TissueSpecimenRequirement.new(:collection_event => cpe, :specimen_type => 'Frozen Tissue')
      pcl
    end
  end
end
