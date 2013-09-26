
require 'thor/group'

module Prophecy

  module Generators
    class New < Thor::Group
      include Thor::Actions

      argument :bookname, :type => :string

      def self.source_root
        File.dirname(__FILE__) + "/book"
      end

      def create_book
        empty_directory(bookname)
      end

      def copy_book
        template("book.yml", "#{bookname}/book.yml")
      end
    end
  end

end
