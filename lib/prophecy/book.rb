
module Prophecy

  class Book

    attr_reader :config, :chapters, :manifest

    attr_reader :title, :subtitle, :author, :publisher, :publisher_atag,
                :publisher_logo, :book_atag, :print_isbn, :ebook_isbn, :uuid, :version, :edition,
      :lang, :lang_iso_639_2, :build_dir, :template_dir, :layouts_dir,
      :assets_dir, :tex_dir, :markdown_dir, :xhtml_dir, :chapter_layout,
      :include_assets, :exclude_assets, :toc, :output_format, :bookid,
      :rights, :creator, :subject, :source, :contributors, :cover_image,
      :date, :compile_name, :show_chapter_name, :chapter_number_format,
      :cover_credit, :file_as

    def initialize(config)
      @config = config.clone

      c = config

      @output_format  = c['output_format']  || nil
      @title          = c['title']          || "The Title"
      @subtitle       = c['subtitle']       || nil
      @author         = c['author']         || "The Author"
      @creator        = c['creator']        || @author
      @file_as        = c['file_as']        || @author
      @publisher      = c['publisher']      || nil
      @publisher_atag = c['publisher_atag'] || nil
      @publisher_logo = c['publisher_logo'] || nil
      @book_atag      = c['book_atag']      || nil
      @print_isbn     = c['print_isbn']     || nil
      @ebook_isbn     = c['ebook_isbn']     || nil
      @uuid           = c['uuid']           || nil
      @version        = c['version']        || 'v0.1'
      @edition        = c['edition']        || nil
      @lang           = c['lang']           || 'en-GB'
      @lang_iso_639_2 = c['lang_iso_639_2'] || @lang.downcase.sub(/-.*$/, '')
      @tex_dir        = c['tex_dir']        || find_format_dir('tex')
      @markdown_dir   = c['markdown_dir']   || find_format_dir('markdown')
      @xhtml_dir      = c['xhtml_dir']      || find_format_dir('xhtml')
      @build_dir      = c['build_dir']      || File.join('./build', @output_format)
      @assets_dir     = c['assets_dir']     || find_assets_dir
      @template_dir   = c['template_dir']   || find_template_dir
      @layouts_dir    = c['layouts_dir']    || File.join(@assets_dir, 'layouts')
      @chapter_layout = c['chapter_layout'] || 'page.xhtml.erb'
      @include_assets = format_include_assets(c['include_assets'])
      @exclude_assets = format_exclude_assets(c['exclude_assets'])
      @toc            = c['toc']            || nil
      @bookid         = c['bookid']         || nil
      @rights         = c['rights']         || nil
      @subject        = c['subject']        || nil
      @source         = c['source']         || nil
      @contributors   = c['contributors']   || nil
      @cover_image    = c['cover_image']    || nil
      @cover_credit   = c['cover_credit']   || nil
      @date           = c['date']           || Time.now.strftime("%Y-%m-%d")
      @show_chapter_name = c['show_chapter_name'] || nil
      @chapter_number_format = c['chapter_number_format'] || nil

      @compile_name = "#{self.author}-#{self.title}-#{Time.now.strftime("%FT%T")}".gsub(/[^a-zA-Z0-9-]/, '-').gsub(/--*/, '-')

      @manifest = nil
      @chapters = []
      Chapter.section_name = config['section_names'] if config['section_names']
      if @toc
        @toc.each do |ch|
          if ch.is_a?(String)
            ch = { 'src' => ch }
          end

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

    def generate_build
      case self.output_format
      when 'epub'
        self.build_epub_mobi
      when 'mobi'
        self.build_epub_mobi
      when 'latex'
        self.build_latex
      else
        warn "Don't know how to build output format: " + self.output_format
        raise "Unknown Output Format Error"
      end
    end

    def build_latex
      FileUtils.cp_r(File.join(@template_dir, '.'), @build_dir)
      FileUtils.cp_r(@include_assets, @build_dir)

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

    def build_epub_mobi
      FileUtils.cp_r(File.join(@template_dir, '.'), @build_dir)
      FileUtils.cp_r(@include_assets, File.join(@build_dir, 'OEBPS'))

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
      when '.md', '.mkd', '.markdown'
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

    private

    def find_format_dir(format)
      if Dir.exists?("./manuscript/#{format}/")
        "./manuscript/#{format}/"
      else
        './manuscript/'
      end
    end

    def find_assets_dir
      if Dir.exists?('./assets/')
        File.join('.', 'assets')
      else
        File.join(File.expand_path(File.dirname(__FILE__)), 'assets')
      end
    end

    def format_include_assets(config_include)
      case (self.output_format)
      when 'epub', 'mobi'
        inc = [
          File.join(self.assets_dir, 'Fonts'),
          File.join(self.assets_dir, 'Images'),
          File.join(self.assets_dir, 'Styles')
        ]
      when 'latex'
        inc = [
          File.join(self.assets_dir, 'Fonts'),
        ]
      end

      if config_include.nil?
        inc
      else
        inc.concat(config_include).uniq
      end
    end

    def format_exclude_assets(config_exclude)
      case (self.output_format)
      when 'epub'
        ex = [ 'ie.css', 'print.css', 'style-mobi.css', '*.swp', '.gitkeep' ]
      when 'mobi'
        ex = [ 'ie.css', 'print.css', 'style-epub.css', '*.swp', '.gitkeep' ]
      when 'latex'
        ex = []
      end

      if config_exclude.nil?
        ex
      else
        ex.concat(config_exclude).uniq
      end
    end

    def find_template_dir
      case (self.output_format)
      when 'epub', 'mobi'
        File.join(self.assets_dir, 'epub_template')
      when 'latex'
        File.join(self.assets_dir, 'latex_template')
      end
    end

  end

end
