
module Prophecy

  class Book

    attr_reader :config, :chapters, :manifest

    attr_reader :title, :subtitle, :author, :publisher, :publisher_atag,
      :publisher_logo, :book_atag, :isbn, :uuid, :version, :edition,
      :lang, :lang_iso_639_2, :tex_dir, :markdown_dir, :xhtml_dir,
      :build_dir, :template_dir, :layouts_dir, :chapter_layout, :assets,
      :exclude_assets, :toc, :output_format, :bookid, :rights, :creator,
      :subject, :source, :contributors, :cover_image, :date,
      :compile_name

    def initialize(config)
      @config = config.clone

      c = config

      @title          = c['title']          || "The Title"
      @subtitle       = c['subtitle']       || nil
      @author         = c['author']         || "The Author"
      @publisher      = c['publisher']      || nil
      @publisher_atag = c['publisher_atag'] || nil
      @publisher_logo = c['publisher_logo'] || nil
      @book_atag       = c['book_atag']     || nil
      @isbn           = c['isbn']           || nil
      @uuid           = c['uuid']           || nil
      @version        = c['version']        || 'v0.1'
      @edition        = c['edition']        || nil
      @lang           = c['lang']           || 'en-GB'
      @lang_iso_639_2 = c['lang_iso_639_2'] || @lang.downcase.sub(/-.*$/, '')
      @tex_dir        = c['tex_dir']        || './manuscript/tex/'
      @markdown_dir   = c['markdown_dir']   || './manuscript/markdown/'
      @xhtml_dir      = c['xhtml_dir']      || './manuscript/xhtml/'
      @build_dir      = c['build_dir']      || nil
      @template_dir   = c['template_dir']   || nil
      @layouts_dir    = c['layouts_dir']    || './assets/layouts/'
      @chapter_layout = c['chapter_layout'] || 'page.xhtml.erb'
      @assets         = c['assets']         || []
      @exclude_assets = c['exclude_assets'] || []
      @toc            = c['toc']            || nil
      @output_format  = c['output_format']  || nil
      @bookid         = c['bookid']         || nil
      @rights         = c['rights']         || nil
      @creator        = c['creator']        || nil
      @subject        = c['subject']        || nil
      @source         = c['source']         || nil
      @contributors   = c['contributors']   || nil
      @cover_image    = c['cover_image']    || nil
      @date           = c['date']           || nil

      @compile_name = "#{self.author}-#{self.title}-#{Time.now.strftime("%FT%T")}".gsub(/[^a-zA-Z0-9-]/, '-').gsub(/--*/, '-')

      @manifest = nil
      @chapters = []
      Chapter.section_name = config['section_names'] if config['section_names']
      if @toc
        @toc.each do |ch|
          if ch.has_key?('target')
            if ch['target'].include?(@output_format) || ch['target'] == @output_format
              @chapters << Chapter.new(self, ch)
            end
          else
            c = Chapter.new(self, ch)
            @chapters << c unless c.render_path.nil?
          end
        end
        @navpoints = @chapters.flat_map{|c| c.navpoints}
      end
    end

    def build_latex
      FileUtils.cp_r(File.join(@template_dir, '.'), @build_dir)
      FileUtils.cp_r(@assets, @build_dir)

      # For ERB binding.
      book = self

      Dir.glob(File.join(@build_dir, '**/*'), File::FNM_DOTMATCH).each do |f|
        if File.extname(f) == '.erb'
          template = ERB.new(IO.read(f))
          text = template.result(binding)
          File.open(f.sub(/\.erb$/, ''), "w"){|file| file << text }
          FileUtils.rm(f)
        end

        @exclude_assets.each do |ex|
          if File.fnmatch(ex, f) || File.fnmatch(ex, File.basename(f))
            FileUtils.rm(f)
          end
        end
      end

      @chapters.each do |ch|
        next if ch.src.nil?
        unless File.extname(ch.src) == '.tex'
          File.open(ch.render_path, "w"){|f| f << ch.to_tex }
        end
      end
    end

    def build_web
      puts "build_web"
    end

    def build_epub_mobi
      FileUtils.cp_r(File.join(@template_dir, '.'), @build_dir)
      FileUtils.cp_r(@assets, File.join(@build_dir, 'OEBPS'))

      content_opf_path = nil

      # For ERB binding.
      book = self

      Dir.glob(File.join(@build_dir, '**/*'), File::FNM_DOTMATCH).each do |f|
        if File.extname(f) == '.erb'
          if File.basename(f) == 'content.opf.erb'
            content_opf_path = File.expand_path(f)
            next
          end
          template = ERB.new(IO.read(f))
          text = template.result(binding)
          File.open(f.sub(/\.erb$/, ''), "w"){|file| file << text }
          FileUtils.rm(f)
        end

        @exclude_assets.each do |ex|
          if File.fnmatch(ex, f) || File.fnmatch(ex, File.basename(f))
            FileUtils.rm(f)
          end
        end
      end

      @chapters.each do |ch|
        File.open(ch.render_path, "w"){|f| f << ch.to_html }
      end

      @manifest = Manifest.new(self)

      # Rendering content.opf.erb at the end.
      unless content_opf_path.nil?
        template = ERB.new(IO.read(content_opf_path))
        text = template.result(binding)
        File.open(content_opf_path.sub(/\.erb$/, ''), "w"){|file| file << text }
        FileUtils.rm(content_opf_path)
      end
    end

    def format_dir(src)
      case File.extname(src)
      when '.md'
        self.markdown_dir
      when '.tex'
        self.tex_dir
      when '.xhtml'
        self.xhtml_dir
      when '.html'
        self.xhtml_dir
      when '.erb'
        self.format_dir(src.sub(/\.erb$/, ''))
      end
    end

    def render_navpoints
      ret = ""
      @navpoints.each_with_index do |nav, idx|
        ret += "<navPoint id='nav#{nav['playOrder']}' playOrder='#{nav['playOrder']}'>\n"
        ret += "<navLabel><text>#{nav['text']}</text></navLabel>\n"
        ret += "<content src='#{nav['src']}'/>"

        next_nav = @navpoints[idx+1]
        if !next_nav.nil? && next_nav['level'] < nav['level']
          d = nav['level'] - next_nav['level'] + 1
          d.times{ ret += "</navPoint>\n" }
        elsif next_nav.nil? || next_nav['level'] == nav['level']
          ret += "</navPoint>\n"
        end
      end
      ret
    end

    def personal_name_first(lastname_comma_name)
      n = lastname_comma_name.split(/, */)
      "#{n[1]} #{n[0]}"
    end

    def epub?
      self.output_format == 'epub'
    end

    def mobi?
      self.output_format == 'mobi'
    end

    def latex?
      self.output_format == 'latex'
    end

  end

end
