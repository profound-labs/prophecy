
require 'thor/group'

module Prophecy

  module Generators
    class New < Thor::Group
      include Thor::Actions

      argument :title, :type => :string

      def self.source_root
        File.dirname(__FILE__)
      end

      def copy_book
        directory('book', "#{title.downcase.gsub(/[^a-z0-9-]/, '')}")
      end
    end
  end

end
