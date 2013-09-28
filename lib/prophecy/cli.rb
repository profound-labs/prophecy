
require 'thor'
require 'prophecy'
require 'prophecy/generators/new'
require 'prophecy/generators/assets'

module Prophecy

  class CLI < Thor

    desc "new \"Title Of Book\"", "start a new book project"
    def new(title)
      Prophecy::Generators::New.start([title, ])
    end

    desc "assets", "get a local copy of the 'assets' folder for customization"
    def assets
      Prophecy::Generators::Assets.start
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
      print "Compiling Epub with Zip... "
      path = File.expand_path("./publish/epub/#{@book.compile_name}.epub")

      if RUBY_PLATFORM =~ /linux|darwin|cygwin/
        binpath = "zip"
      elsif RUBY_PLATFORM =~ /mingw|mswin32/
        binpath = File.expand_path(File.join(__FILE__, '..', '..', '..', 'bin/zip.exe'))
      end

      cmd = "{ cd #{@book.build_dir}"
      cmd += " && #{binpath} -X \"#{path}\" mimetype"
      cmd += " && #{binpath} -rg \"#{path}\" META-INF"
      cmd += " && #{binpath} -rg \"#{path}\" OEBPS; } > zip.log 2>&1"

      if system(cmd)
        puts "OK"
        puts "Find the Epub file in ./publish/epub"
      else
        puts "Error. See zip.log"
        exit 2
      end

      #puts "Validating with epubcheck"
      #cmd = system("epubcheck builds/epub/book.epub")
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
      print "Compiling Epub (for Mobi) with Zip... "
      path = File.expand_path("./#{@book.compile_name}.epub")

      if RUBY_PLATFORM =~ /linux|darwin|cygwin/
        binpath = "zip"
      elsif RUBY_PLATFORM =~ /mingw|mswin32/
        binpath = File.expand_path(File.join(__FILE__, '..', '..', '..', 'bin/zip.exe'))
      end

      cmd = "{ cd #{@book.build_dir}"
      cmd += " && #{binpath} -X \"#{path}\" mimetype"
      cmd += " && #{binpath} -rg \"#{path}\" META-INF"
      cmd += " && #{binpath} -rg \"#{path}\" OEBPS; } > zip.log 2>&1"

      if system(cmd)
        puts "OK"
      else
        puts "Error. See zip.log"
        exit 2
      end

      # Kindlegen
      print "Converting Epub with Kindlegen... "

      binpath = File.expand_path(File.join(__FILE__, '..', '..', '..', 'bin/kindlegen'))
      cmd = "{ #{binpath} \"#{@book.compile_name}.epub\""
      cmd += " && mv \"#{@book.compile_name}.mobi\" ./publish/mobi/"
      cmd += " && rm \"#{@book.compile_name}.epub\"; } > kindlegen.log 2>&1"

      if system(cmd)
        puts "OK"
      else
        puts "Error. See kindlegen.log"
        exit 2
      end

      # Stripping extra source
      print "Stripping the SRCS record (source files) from the Mobi with Kindlestrip... "

      binpath = File.expand_path(File.join(__FILE__, '..', '..', '..', 'bin/kindlestrip.py'))
      cmd = "{ #{binpath} \"./publish/mobi/#{@book.compile_name}.mobi\" \"./publish/mobi/#{@book.compile_name}.stripped.mobi\""
      cmd += " && mv \"./publish/mobi/#{@book.compile_name}.stripped.mobi\" \"./publish/mobi/#{@book.compile_name}.mobi\"; } > kindlestrip.log 2>&1"

      if system(cmd)
        puts "OK"
        puts "Find the Mobi file in ./publish/mobi"
      else
        puts "Error. See kindlestrip.log"
        exit 2
      end

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
