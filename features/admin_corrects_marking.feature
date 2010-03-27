Feature: Admin corrects marking
  In order to show the legit comments
  As a site admin
  I want to be able to mark false positives and negatives

  Scenario: False positive (ham marked as spam)
    Given I have a hammy comment
    And it is marked as spam
    When I mark it as a false positive
    Then it should be marked as ham

  Scenario: False negative (spam marked as ham)
    Given I have a spammy comment
    And it is marked as ham
    When I mark it as a false negative
    Then it should be marked as spam
