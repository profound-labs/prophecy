Prophecy Book Boilerplate
=========================

Book boilerplate to generate books as EPUB, MOBI, and PDF from simple
Markdown text files. Or from HTML. Or from LaTeX. Or mixed.

Page layout, CSS typography, the format standards, TOC navPoints,
manifest, guide -- is the litany of pain.

Sounds like the machine should be doing this, and we can just go and
meditate on peace.

    $ gem install prophecy
    $ prophecy new "This World"
    $ cd thisworld
    $ vim book.yml
    $ prophecy epub && prophecy mobi && prophecy latex

## Let's see that

[![Screencast demo][demo-jpg]](http://asciinema.org/a/5680)

[demo-jpg]: http://profound-labs.github.io/projects/prophecy/prophecy-screencast.jpg

Demo: [asciinema.org/a/5680](http://asciinema.org/a/5680)

## And then this happens

Add Screeshots.

Embedded fonts and CSS typography for the ebooks, and a LaTeX
documentclass for the PDF.

## Onwards

Add docs for...

- Overview
- Installation for Linux, OS/X, Windows
- Custom page templates
- Custom CSS style

Home: [profound-labs.github.io/projects/prophecy/](http://profound-labs.github.io/projects/prophecy/)

Github: [profound-labs/prophecy](https://github.com/profound-labs/prophecy)

Rubygems: [prophecy](https://rubygems.org/gems/prophecy)

## Inspried by

[bookshop](https://github.com/blueheadpublishing/bookshop), [kitabu](https://github.com/fnando/kitabu), and the [gem guide](https://github.com/radar/guides/blob/master/gem-development.md).

