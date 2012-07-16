require 'spec/spec_helper'
require 'jinx/helpers/string_uniquifier'
require 'scat/edit'
require File.dirname(__FILE__) + '/../test/fixtures/seed'

describe Scat do
  describe 'Edit' do
    before(:all) do
      title = Jinx::StringUniquifier.uniquify('Scat')
      pcl = Scat::Seed.protocol_for(title).find(:create)
      @params = {
        :user => pcl.coordinators.first,
        :protocol => title,
        :mrn => Jinx::StringUniquifier.uniquify('Test'),
        :spn => Jinx::StringUniquifier.uniquify('Test'),
        :diagnosis => '[M]Adrenal cortical adenoma NOS',
        :tissue_site => 'Adrenal gland, NOS',
        :malignant => 'Malignant',
        :quantity => '4'
      }
      @spc = Scat::Edit.instance.save(@params)
    end
    
    subject { @spc }
    
    it "should save the specimen" do
      subject.identifier.should_not be nil
    end
    
    it "should set the properties" do
      subject.pathological_status.should == 'Malignant' 
      scg = subject.specimen_collection_group
      scg.clinical_diagnosis.should == '[M]Adrenal cortical adenoma NOS' 
      subject.characteristics.tissue_site.should == 'Adrenal gland, NOS' 
      subject.initial_quantity.should == 4.0 
    end
    
    context "add a normal specimen to an existing SCG" do
      before(:all) do
        oparams = @params.delete_if { |k, v| k == :malignant }
        oparams[:quantity] = '5'
        @other = Scat::Edit.instance.save(oparams)
      end  
      
      it "should save the additional specimen" do 
        @other.identifier.should_not be nil
        @other.identifier.should_not == subject.identifier
        @other.initial_quantity.should == 5.0 
      end
      
      it "should be non-malignant" do 
        @other.pathological_status.should == 'Non-Malignant'
      end
      
      it "should use the same SCG" do
        @other.specimen_collection_group.identifier.should be subject.specimen_collection_group.identifier
      end
    end
  end
end
