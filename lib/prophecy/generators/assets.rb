
require 'thor/group'

module Prophecy

  module Generators
    class Assets < Thor::Group
      include Thor::Actions

      def self.source_root
        File.dirname(__FILE__)
      end

      def copy_assets
        unless File.exists?('book.yml')
          warn "Cancelled. This doesn't look like a book project folder (there's no book.yml)."
          exit 2
        end
        if Dir.exists?('assets')
          warn "Cancelled. There is already an 'assets' folder here. Move it or delete it manually if you want a new copy."
          exit 2
        end
        directory(File.join('..', 'assets'), "assets")
      end
    end
  end

end

