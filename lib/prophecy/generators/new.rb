
require 'thor/group'

module Prophecy

  module Generators
    class New < Thor::Group
      include Thor::Actions

      argument :title, :type => :string

      def self.source_root
        File.dirname(__FILE__) + "/book"
      end

      def copy_book
        directory("#{title}")
      end
    end
  end

end
