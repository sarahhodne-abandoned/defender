Feature: User submits comment
  In order to comment on an article
  As a reader
  I want to submit comments

  Scenario: Legit comment (ham)
    Given I have a hammy comment
    When I save it
    Then it should be marked as ham

  Scenario: Spam comment
    Given I have a spammy comment
    When I save it
    Then it should be marked as spam
