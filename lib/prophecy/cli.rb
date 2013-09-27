
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
      system "cd #{@book.build_dir} && zip -X #{path} mimetype"
      system "cd #{@book.build_dir} && zip -rg #{path} META-INF"
      system "cd #{@book.build_dir} && zip -rg #{path} OEBPS"
    end

    desc "mobi", "generate MOBI with Kindlegen"
    def mobi
      @config = YAML::load(IO.read('book.yml'))
      # Local assets dir in book project folder
      compile_assets if Dir.exists?('./assets') && @assets_dir == File.join('.', 'assets')
      @book = mobi_init_book
      clean_dir(@book.build_dir)
      @book.generate_build

      # Compile Epub with Zip for conversion with kindlegen
      path = File.expand_path("./#{@book.compile_name}.epub")
      system "cd #{@book.build_dir} && zip -X #{path} mimetype"
      system "cd #{@book.build_dir} && zip -rg #{path} META-INF"
      system "cd #{@book.build_dir} && zip -rg #{path} OEBPS"

      # Kindlegen
      #system "kindlegen '#{@book.compile_name}.epub' -c2 -o '#{@book.compile_name}.mobi'"
      #system "mv '#{@book.compile_name}.mobi' ./publish/mobi/"
      #system "rm '#{@book.compile_name}.epub'"
    end

    desc "pdf", "generate PDF with LaTeX"
    def pdf
      @config = YAML::load(IO.read('book.yml'))
      @book = latex_init_book
      clean_dir(@book.build_dir)
      @book.generate_build
      system "cd #{@book.build_dir} && make"
    end

    desc "to_markdown", "convert .tex files to markdown"
    def to_markdown
      @book = latex_init_book

      Dir[File.join(@book.tex_dir, '*.tex')].each do |f|
        dest = File.expand_path(File.join(@book.markdown_dir, File.basename(f).sub(/\.tex$/, '.md')))
        if File.exist?(dest)
          print "WARNING: destination exists: #{dest}\nOverwrite? [yN] "
          a = STDIN.gets.chomp()
          if a.downcase != 'y'
            puts "OK, skipping file"
            next
          end
        end
        r = system "/bin/bash #{File.join(@book.assets_dir, 'helpers/tex2md.sh')} '#{File.expand_path(f)}' '#{dest}'"
        warn "WARNING: tex2md.sh returned non-zero for #{f}" unless r
      end
    end

    private

    def epub_init_book
      [ './epub_mobi.yml',
        './epub.yml' ].each do |c|
        next if !File.exists?(c)
        h = YAML::load(IO.read(c))
        @config.merge!(h) if h
      end

      @config['output_format'] ||= 'epub'
      Prophecy::Book.new(@config)
    end

    def mobi_init_book
      [ './epub_mobi.yml',
        './mobi.yml' ].each do |c|
        next if !File.exists?(c)
        h = YAML::load(IO.read(c))
        @config.merge!(h) if h
      end

      @config['output_format'] ||= 'mobi'
      Prophecy::Book.new(@config)
    end

    def latex_init_book
      [ './latex.yml', ].each do |c|
        next if !File.exists?(c)
        h = YAML::load(IO.read(c))
        @config.merge!(h) if h
      end

      @config['output_format'] ||= 'latex'
      @book = Prophecy::Book.new(@config)
    end

    def compile_assets
      system 'cd assets && compass compile'
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
      system "rm -rf #{File.join(dir, '*')}"
    end

  end

end
