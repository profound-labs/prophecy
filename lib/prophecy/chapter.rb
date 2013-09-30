
module Prophecy

  class Chapter

    attr_accessor :title, :id, :idref, :lang, :class, :book, :level,
      :layout, :src, :path, :render_name, :render_path, :href, :type,
      :linear, :prefix, :postfix, :insert, :section_name,
      :section_number, :navpoints

    # Array index corresponds to level, levels index from 0 too. In the
    # .yml you give the level: N attrib as if they were indexed from 1,
    # makes more sense there, but we compensate for it in the class.

    @@section_name = [ "Chapter", ]
    @@section_number = [ 0, ]
    @@toc_from_headers = false
    @@playOrder = 1

    @@the_matter = 'frontmatter'

    def initialize(book, config)
      @book = book

      if @book.output_format == 'mobi'
        unless config['level'].nil?
          lvl = config['level'].to_i - 1
          if lvl > 1
            @level = 1
          else
            @level = lvl
          end
        else
          @level = 0
        end
      else
        if config['level'].nil?
          @level = 0
        else
          @level = config['level'].to_i - 1
        end
      end

      if config['the_matter']
        @the_matter = config['the_matter']
        @@the_matter = config['the_matter']
      else
        @the_matter = @@the_matter
      end

      @linear = config['linear'] || nil

      @src = nil
      if config.is_a?(String)
        @src = config
      elsif config.is_a?(Hash) && config.has_key?('src')
        @src = config['src']
      end

      ext_for_output = {
        'epub' => '.xhtml',
        'mobi' => '.xhtml',
        'latex' => '.tex',
        'web' => '.html'
      }

      chapters_dir_for_output = {
        'epub' => File.join('OEBPS', 'chapters'),
        'mobi' => File.join('OEBPS', 'chapters'),
        'latex' => 'chapters',
        'web' => 'chapters',
      }

      @path = nil
      @href = nil

      unless @src.nil?
        @render_ext = ext_for_output[book.output_format]

        path = nil
        try_folders = [ book.format_dir(@src), 'manuscript' ].uniq
        try_folders.each do |dir|
          path = File.join(dir, @src)
          if File.exists?(path)
            @path = path
            break
          end
        end

        unless @path
          puts "Error. Cannot find #{@src} in folders #{try_folders.join(', ')}"
          exit 2
        end

        @render_name = File.basename(@path).sub(/\.erb$/, '').sub(/\.[^\.]+$/, @render_ext)
        @render_path = File.expand_path(
          File.join(
            self.book.build_dir,
            chapters_dir_for_output[book.output_format],
            @render_name
          )
        )

        a = Pathname.new(self.render_path)
        b = Pathname.new(File.expand_path(
          File.join(
            self.book.build_dir,
            chapters_dir_for_output[book.output_format],
            '..'
          )
        ))
        @href = a.relative_path_from(b)
      end

      @type = config['type'] || nil
      @title = config['title'] || self.first_header_text || ""
      @class = config['class'] || ""
      @class += " #{@type}" if @type
      @id = config['id'] || 'chapter_' + @title.downcase.gsub(/[^a-z0-9-]/, '-').gsub(/--+/, '-')
      @lang = config['lang'] || book.lang
      @prefix = config['prefix'] || nil
      @postfix = config['postfix'] || nil
      @insert = config['insert'] || nil

      if config['section_name']
        @@section_name[@level] = config['section_name']
      else
      end
      if config['section_number']
        @@section_number[@level] = config['section_number'].to_i - 1
      elsif @@section_number[@level].nil?
        @@section_number[@level] = 1
      elsif !@path.nil?
        @@section_number[@level] += 1
      end
      @section_name = @@section_name[@level]
      @section_number = @@section_number[@level]

      @@toc_from_headers = config['toc_from_headers'] unless config['toc_from_headers'].nil?

      @navpoints = []
      if @path
        if @@toc_from_headers
          doc = Nokogiri::HTML(self.to_html)
          headers = doc.xpath("//*[name()='h1' or name()='h2' or name()='h3' or name()='h4']")
          headers.each do |h|
            # skip links (<a href=""> tag) in header (possibly end- or footnote references)
            t = ""
            h.children.select{|i| i.name != 'a'}.each{|s| t += s}
            @navpoints << {
              'text' => CGI.escapeHTML(t),
              'src' => "chapters/#{@render_name}##{h.attributes['id']}",
              'playOrder' => @@playOrder,
              'level' => @level,
            }
            @@playOrder += 1
          end
        else
          @navpoints << {
            'text' => @title,
            'src' => "chapters/#{@render_name}",
            'playOrder' => @@playOrder,
            'level' => @level,
          }
          @@playOrder += 1
        end
      end

      if config['layout'].nil?
        @layout_path = File.join(book.layouts_dir, book.chapter_layout)
      elsif config['layout'] == 'nil' || config['layout'] == 'none'
        @layout_path = nil
      else
        @layout_path = File.join(book.layouts_dir, config['layout'])
      end
    end

    def idref
      self.book.manifest.items.select do |i|
        File.expand_path(i.path) == self.render_path
      end.first.id
    end

    def first_header_text
      if @path
        doc = Nokogiri::HTML(self.to_html)
        h = doc.xpath("//*[name()='h1' or name()='h2' or name()='h3' or name()='h4']").first
        h.text.strip if h
      else
        nil
      end
    end

    def to_guide_reference
      return "" if @type.nil?
      ret = "<reference href='#{@href}' title=\"#{@title.gsub('"', "'")}\""
      ret += " type='#{@type}'"
      ret += " />"
    end

    def to_html(format = nil, text = nil, layout_path = @layout_path)
      format ||= File.extname(@path)
      text ||= IO.read(@path)
      # for ERB binding
      book = self.book
      chapter = self

      ret = nil

      case format
      when '.html', '.xhtml'
        ret = text
      when '.md', '.mkd', '.markdown'
        ret = Kramdown::Document.new(text).to_html
      when '.tex'
        # Is Pandoc installed?
        unless system("pandoc --version > /dev/null 2>&1")
          puts "Error. Pandoc not found, I'll need that for TeX to HTML conversion."
          exit 2
        end
        File.open('./temp-chapter.tex', 'w'){|f| f << text }
        r = system 'pandoc --smart --normalize --from=latex --to=html -o ./temp-chapter.xhtml ./temp-chapter.tex'
        warn "WARNING: pandoc returned non-zero for #{self.to_s}" unless r
        ret = IO.read('./temp-chapter.xhtml')
        FileUtils.rm(['./temp-chapter.tex', './temp-chapter.xhtml'])
      when '.erb'
        template = ERB.new(text)
        fmt = File.extname(@path.sub(/#{format}$/, ''))
        return self.to_html(format = fmt, text = template.result(binding))
      else
        warn "Don't know how to render: #{@src}"
        raise "Error while rendering chapter"
      end

      unless layout_path.nil?
        template = ERB.new(IO.read(layout_path))
        content = ret
        template.result(binding)
      else
        ret
      end
    end

    def to_tex(format = nil, text = nil, layout_path = @layout_path)
      format ||= File.extname(@path)
      text ||= IO.read(@path)
      # for ERB binding
      book = self.book
      chapter = self

      ret = nil

      case format
      when '.html', '.xhtml'
        # Is Pandoc installed?
        unless system("pandoc --version > /dev/null 2>&1")
          puts "Error. Pandoc not found, I'll need that for HTML to TeX conversion."
          exit 2
        end
        File.open('./temp-chapter.html', 'w'){|f| f << text }
        system 'pandoc --smart --normalize --chapters --from=html --to=latex -o ./temp-chapter.tex ./temp-chapter.html'
        ret = IO.read('./temp-chapter.tex')
        FileUtils.rm(['./temp-chapter.tex', './temp-chapter.html'])
      when '.md', '.mkd', '.markdown'
        ret = Kramdown::Document.new(text, options = {:latex_headers => %w{chapter section subsection subsubsection paragraph subparagraph}}).to_latex
      when '.tex'
        ret = text
      when '.erb'
        template = ERB.new(text)
        fmt = File.extname(@path.sub(/#{format}$/, ''))
        ret = self.to_tex(format = fmt, text = template.result(binding))
      else
        warn "Don't know how to render: #{@src}"
        raise "Error while rendering chapter"
      end

      ret
    end

    def to_spineitem
      ret = "<itemref idref='#{self.idref}' "
      ret += "linear='#{self.linear}'" unless self.linear.nil?
      ret += " />"
    end

    def to_chapterlist
      return "#{@insert}" if @insert
      ret = ""
      ret += @prefix + "\n" if @prefix

      if @src
        ret += "% #{@title}\n" unless @title.empty?
        if File.extname(@src) == '.tex'
          ret += "\\input{" + File.join('..', '..', @book.tex_dir, @src) + "}"
        else
          ret += "\\input{#{@href}}"
        end
      end
      ret += "\n" + @postfix if @postfix
      ret
    end

    def to_toc_li
      "<li><a href='../chapters/#{@render_name}'><span>#{@title}</span></a></li>"
    end

    def to_toc_tr
      ret = ""
      @navpoints.each do |nav|
        ret += "<tr>\n"
        # Section name and number
        ret += "<td class='section'>\n"
        if self.mainmatter? && !@section_name.nil? && !@section_name.empty?
          ret += "#{@section_name} #{@section_number}"
        end
        ret += "</td>\n"
        # Separator
        ret += "<td class='separator'>"
        if self.mainmatter? && !@section_name.nil? && !@section_name.empty?
          ret += " &middot; "
        end
        ret += "</td>\n"
        # Title
        ret += "<td class='title #{@the_matter}'>\n"
        ret += "<a href='#{File.join('..', 'chapters', File.basename(nav['src']))}'><span>#{nav['text']}</span></a>\n"
        ret += "</td>\n"
        ret += "</tr>"
      end
      ret
    end

    def frontmatter?
      @the_matter == 'frontmatter'
    end

    def mainmatter?
      @the_matter == 'mainmatter'
    end

    def backmatter?
      @the_matter == 'backmatter'
    end

    def self.section_name
      @@section_name
    end

    def self.section_name=(a)
      @@section_name = a
    end

    def self.section_number
      @@section_number
    end

    def self.section_number=(a)
      @@section_number = a
    end

    def self.toc_from_headers
      @@toc_from_headers
    end

    def self.toc_from_headers=(b)
      @@toc_from_headers = b
    end

    def self.the_matter
      @@the_matter
    end

    def self.the_matter=(s)
      @@the_matter = s
    end

    def to_s
      [@title, @path].join(", ")
    end
  end

end

