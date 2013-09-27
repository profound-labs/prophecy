
require 'thor'
require 'prophecy'
require 'prophecy/generators/new'

module Prophecy

  class CLI < Thor

    desc "book_title", "Print book title"
    def book_title
      # call Prophecy::Book to get the title
      puts "Title: who knows?"
    end

    desc "new TITLE", "start a new book project"
    def new(title)
      Prophecy::Generators::New.start([title, ])
    end

    #desc "epub", "generate EPUB"
    #def epub
    #  Prophecy::Book.build_epub_mobi("epub")
    #end

    #desc "mobi", "generate MOBI"
    #def mobi
    #  Prophecy::Book.build_epub_mobi("mobi")
    #end

    #desc "pdf", "generate PDF"
    #def pdf
    #  Prophecy::Book.build_latex
    #end

  end

end
