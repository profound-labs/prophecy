
Feature: Book
  In order to get the title
  As a CLI
  I want no waste of time

  Scenario: Book has title
    When I run `prophecy book_title`
    Then the output should contain "Title:"

