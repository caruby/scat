require 'spec/spec_helper'

describe Scat do
  describe 'Auto-complete' do
    include Scat::Autocomplete
    
    AC_TARGET ||= 'Malignant lymphoma'
    
    it "should find matching diagnoses" do
      matches = autocomplete(:clinical_diagnosis, AC_TARGET) 
      matches.should_not be_empty
      matches.each do |cv|
        cv.downcase.should match AC_TARGET.downcase
      end
    end
  end
end
