Feature: Save
  In order to add a specimen
  As a biobank technician
  I submit an edit
  
  Scenario: Submit an edit
    Given I am on the home page
    And the protocol "Scat" exists
    When I fill in "Protocol" with "Scat"
    And I fill in "MRN" with "123"
    And I fill in "SPN" with "SP-123"
    And I fill in "Diagnosis" with "[M]Adrenal cortical adenoma NOS"
    And I fill in "Tissue Site" with "Adrenal gland, NOS"
    And I fill in "Quantity" with "4"
    And I am authorized
    And I click "Save"
    Then the edit is saved
