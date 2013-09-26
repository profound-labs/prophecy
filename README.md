Prophecy Book Boilerplate
=========================

**WORK IN PROGRESS. The code is being re-organized as a ruby gem.**

Book boilerplate to generate books as EPUB, MOBI, and PDF from simple
Markdown text files. Embedded fonts and CSS typography for the ebooks,
and a pretty LaTeX documentclass for the PDF.

Home: [profound-labs.github.io/projects/prophecy/](http://profound-labs.github.io/projects/prophecy/)

Github: [profound-labs/prophecy](https://github.com/profound-labs/prophecy)

Build a book as a PDF, EPUB and MOBI.

The manuscript can be in Markdown (kramdown), LaTeX or HTML. Use the
same manuscript files for the different target formats or mix them as
needed.

This tool will generate the TOC files (.ncx and .xhtml), Manifest and
the rest.

## Installation

    $ gem install prophecy

## Usage

1. Start a new book: `$ prophecy new bookname`, this will create a
   folder `bookname` with skeleton files to get started with.
1. Add the manuscript to `manuscript/` (in Markdown, LaTeX or HTML)
2. Fill out basic book info in `book.yml`
3. Compile the book: `prophecy epub`, `prophecy mobi` or `prophecy pdf` if you have
   LaTeX installed
4. Done! Grab the files from the `publish/` folder

## Inspried by

[bookshop](https://github.com/blueheadpublishing/bookshop), [kitabu](https://github.com/fnando/kitabu), and Ryan Bigg's [gem building guide](https://github.com/radar/guides/blob/master/gem-development.md).

