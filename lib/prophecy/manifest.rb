
module Prophecy

  class Manifest

    attr_accessor :items

    def initialize(book)
      @items = []
      @dir = File.expand_path(File.join(book.build_dir, 'OEBPS'))
      Dir[File.join(@dir, '**/*')].each do |f|
        next if File.directory?(f)
        next if File.fnmatch('content.opf*', File.basename(f))
        @items << ManifestItem.new(book, @dir, f)
      end
    end

    def find_by_filename(filename)
      @items.select{|i| File.basename(i.path) == File.basename(filename) }.first.href
    end

  end

  class ManifestItem

    attr_reader :href, :id, :path, :dir

    def initialize(book, dir, itempath)
      @book = book
      @dir = Pathname.new(File.expand_path(dir))
      @path = Pathname.new(File.expand_path(itempath))

      @href = @path.relative_path_from(@dir)

      if File.basename(@path.to_s) == 'toc.ncx'
        @id = 'ncx'
      elsif !book.cover_image.nil? && File.basename(book.cover_image) == File.basename(itempath)
        @id = 'cover-image'
      else
        @id = self.chapter_id || @href.to_s.downcase.gsub(/[^a-z0-9-]/, '-').gsub(/--+/, '-')
      end
    end

    def chapter_id
      ret = @book.chapters.select{|ch| ch.render_path == @path.to_s }.first
      ret.id if ret
    end

    def media_type
      ret = ""
      # first, use the known list
      ext = File.extname(@path)
      types = {
        '.ncx' => 'application/x-dtbncx+xml',
        '.ttf' => 'application/x-font-ttf',
        '.otf' => 'application/vnd.ms-opentype',
      }
      if types.has_key?(ext)
        ret = types[ext]
      end
      # if not, ask from MIME::Types
      ret = MIME::Types.type_for(File.basename(@path)).first.to_s if ret == ""
      if ret == ""
        warn "Can't determine media type for: #{@path}"
        raise "Unknown Media Type"
      end

      ret
    end

    def to_s
      @path.to_s
    end

  end

end
