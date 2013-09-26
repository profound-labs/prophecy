
Feature: Generate new books
  In order to start a new book
  As a CLI
  I want to get a skeleton folder

  Scenario: Starting a new book
    When I run `prophecy new hiddenway`
    Then the following files should exist:
      | hiddenway/book.yml |
    Then the file "hiddenway/book.yml" should contain:
      """
      title: hiddenway
      """
