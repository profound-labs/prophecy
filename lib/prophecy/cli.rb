
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

    desc "epub", "Generate new EPUB from sources. This calls assets_compile, epub_clean_dir, epub_build, epub_compile."
    def epub
      epub_init
      assets_compile
      epub_clean_dir
      epub_build
      epub_compile
    end

    desc "epub_clean_dir", "Delete everything in the EPUB build dir"
    def epub_clean_dir
      epub_init
      clean_dir
    end

    desc "epub_build", "Generate EPUB build files from the templates and manuscript"
    def epub_build
      epub_init
      @book.generate_build
    end

    desc "epub_compile", "Compile EPUB file from the build dir"
    def epub_compile
      epub_init

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

    desc "mobi", "Generate new MOBI with Kindlegen from sources. This calls assets_compile, mobi_clean_dir, mobi_build, mobi_compile."
    def mobi
      mobi_init
      assets_compile
      mobi_clean_dir
      mobi_build
      mobi_compile
    end

    desc "mobi_clean_dir", "Delete everything in the MOBI build dir"
    def mobi_clean_dir
      mobi_init
      clean_dir
    end

    desc "mobi_build", "Generate MOBI build files from the templates and manuscript"
    def mobi_build
      mobi_init
      @book.generate_build
    end

    desc "mobi_compile", "Compile MOBI file from the build dir"
    def mobi_compile
      mobi_init

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

    desc "latex", "Generate new PDF with LaTeX from sources. This calls latex_clean_dir, latex_build, latex_compile"
    def latex
      latex_init
      latex_clean_dir
      latex_build
      latex_compile
    end

    desc "latex_clean_dir", "Delete everything in the LaTeX build dir"
    def latex_clean_dir
      latex_init
      clean_dir
    end

    desc "latex_build", "Generate LaTeX build files from the templates and manuscript"
    def latex_build
      latex_init
      @book.generate_build
    end

    desc "latex_compile", "Compile PDF file from the LaTeX build dir"
    def latex_compile
      latex_init

      # Is LuaLatex installed?
      unless system("lualatex --version > /dev/null 2>&1")
        puts "Error. LuaLaTeX not found."
        exit 2
      end

      print "Running 'make' in #{@book.build_dir} ... "

      cmd = "{ cd #{@book.build_dir}"
      cmd += " && make"
      cmd += " && cp book_main.pdf ../../publish/pdf/; } > lualatex.log 2>&1"

      if system(cmd)
        puts "OK"
        puts "Find book_main.pdf in ./build/latex/ and ./publish/pdf"
      else
        puts "Error. See lualatex.log and ./build/latex/book_main.log"
        exit 2
      end
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

    desc "assets_compile", "Compile assets (run compass, etc.) if there is a local assets folder"
    def assets_compile
      unless Dir.exists?('./assets')
        return
      end
      puts "Running 'compass compile' ..."
      if system 'cd assets && compass compile'
        puts "OK"
      else
        puts "Error"
        exit 2
      end
    end

    private

    def epub_init
      @config ||= YAML::load(IO.read('book.yml'))

      [ './epub_mobi.yml',
        './epub.yml' ].each do |c|
        next if !File.exists?(c)
        h = YAML::load(IO.read(c))
        @config.merge!(h) if h
      end

      @config['output_format'] ||= 'epub'
      @book ||= Prophecy::Book.new(@config)
    end

    def mobi_init
      @config ||= YAML::load(IO.read('book.yml'))

      [ './epub_mobi.yml',
        './mobi.yml' ].each do |c|
        next if !File.exists?(c)
        h = YAML::load(IO.read(c))
        @config.merge!(h) if h
      end

      @config['output_format'] ||= 'mobi'
      @book ||= Prophecy::Book.new(@config)
    end

    def latex_init
      @config ||= YAML::load(IO.read('book.yml'))

      [ './latex.yml', ].each do |c|
        next if !File.exists?(c)
        h = YAML::load(IO.read(c))
        @config.merge!(h) if h
      end

      @config['output_format'] ||= 'latex'
      @book ||= Prophecy::Book.new(@config)
    end

    def clean_dir
      dir = @book.build_dir
      puts "Cleaning #{dir} ..."
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
