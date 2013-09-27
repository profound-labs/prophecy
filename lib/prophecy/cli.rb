
require 'thor'
require 'prophecy'
require 'prophecy/generators/new'

module Prophecy

  class CLI < Thor

    desc "title", "Print book title"
    def title
      @config = YAML::load(IO.read('book.yml'))
      @book = epub_init_book
      puts @book.title
    end

    desc "new \"Title Of Book\"", "start a new book project"
    def new(title)
      Prophecy::Generators::New.start([title, ])
    end

    desc "epub", "generate EPUB"
    def epub
      @config = YAML::load(IO.read('book.yml'))
      # Local assets dir in book project folder
      compile_assets if Dir.exists?('./assets') && @assets_dir == File.join('.', 'assets')
      @book = epub_init_book
      clean_dir(@book.build_dir)
      @book.generate_build

      # Compile Epub with Zip
      path = File.expand_path("./publish/epub/#{@book.compile_name}.epub")
      sh "cd #{@book.build_dir} && zip -X #{path} mimetype"
      sh "cd #{@book.build_dir} && zip -rg #{path} META-INF"
      sh "cd #{@book.build_dir} && zip -rg #{path} OEBPS"
    end

    #desc "mobi", "generate MOBI"
    #def mobi
    #  Prophecy::Book.build_epub_mobi("mobi")
    #end

    #desc "pdf", "generate PDF"
    #def pdf
    #  Prophecy::Book.build_latex
    #end

    private

    def epub_init_book
      [ './config/epub_mobi.yml',
        './config/epub.yml' ].each do |c|
        h = YAML::load(IO.read(c))
        @config.merge!(h) if h
      end

      @config['output_format'] ||= 'epub'
      @config['template_dir'] ||= './assets/epub_template/'
      @config['build_dir'] ||= './build/epub/'

      VolumeOne::Book.new(@config)
    end

    def mobi_init_book
      [ './config/epub_mobi.yml',
        './config/mobi.yml' ].each do |c|
        h = YAML::load(IO.read(c))
        @config.merge!(h) if h
      end

      @config['output_format'] ||= 'mobi'
      @config['template_dir'] ||= './assets/epub_template/'
      @config['build_dir'] ||= './build/mobi/'

      VolumeOne::Book.new(@config)
    end

    def latex_init_book
      [ './config/latex.yml', ].each do |c|
        h = YAML::load(IO.read(c))
        @config.merge!(h) if h
      end

      @config['output_format'] ||= 'latex'
      @config['template_dir'] ||= './assets/latex_template/'
      @config['build_dir'] ||= './build/latex/'

      @book = VolumeOne::Book.new(@config)
    end

    def compile_assets
      sh 'cd assets && compass compile'
    end

    def clean_dir(dir)
      if Dir[File.join(dir, '*')].empty?
        puts "#{dir} is empty."
        return
      end
      print "Delete everything in #{dir} ? [yN] "
      a = STDIN.gets.chomp()
      if a.downcase != 'y'
        puts "Cancelled, bye!"
        exit
      end
      sh "rm -rf #{File.join(dir, '*')}"
    end

  end

end
