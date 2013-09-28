
Feature: Generate new books
  In order to start a new book
  As a CLI
  I want to get a skeleton folder

  Scenario: Starting a new book
    When I run `prophecy new "The Hidden Way"`
    Then the following files should exist:
      | thehiddenway/book.yml |
    Then the file "thehiddenway/book.yml" should contain:
      """
      title: "The Hidden Way"
      """

