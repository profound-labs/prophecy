
Feature: Copy assets directory
  In order to customize assets
  As a CLI
  I want to get the assets folder

  Scenario: Inside a book project folder
    When I run `prophecy new "The Hidden Way"`
    Given I cd to "thehiddenway"
    When I run `prophecy assets`
    Then the following files should exist:
      | book.yml |
      | assets/epub_template/OEBPS/toc.ncx.erb |

