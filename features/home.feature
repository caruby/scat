Feature: Home
  In order to use Scat
  As a biobank technician
  I visit the home page
  
  Scenario: Visit home
    Given I am on the home page
    Then I should see the "Protocol" field
    And I should see the "MRN" field
    And I should see the "SPN" field
    And I should see the "Diagnosis" field
    And I should see the "Tissue Site" field
    And I should see the "Quantity" field
 