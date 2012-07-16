Feature: Edit
  In order to use Scat
  As a biobank technician
  I submit an edit
  
  Scenario: Visit edit
    Given I am on the edit page
    Then I should see the "Protocol" field
    And I should see the "MRN" field
    And I should see the "SPN" field
    And I should see the "Diagnosis" field
    And I should see the "Tissue Site" field
    And I should see the "Quantity" field
    And I should see the "Malignant" field

  Scenario: Submit an edit
    Given I am on the edit page
    And the protocol "Scat" exists
    When I fill in "Protocol" with "Scat"
    And I fill in "MRN" with "123"
    And I fill in "SPN" with "SP-123"
    And I fill in "Diagnosis" with "[M]Adrenal cortical adenoma NOS"
    And I fill in "Tissue Site" with "Adrenal gland, NOS"
    And I fill in "Quantity" with "4"
    And I check the "Malignant" checkbox
    And I am authorized
    And I click "Save"
    Then the status should show the label
    And the specimen should be saved 
