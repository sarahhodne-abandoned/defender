Feature: Admin retrieves document
  In order to find the information of a document after sending it
  As an admin
  I want to be able to retrieve it

  Scenario: Retrieve document
    Given I have submitted a document
    When I retrieve the document from the server
    Then it should have the same data
    And it should have the same signature
