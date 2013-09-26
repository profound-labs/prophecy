
require 'prophecy'

describe Prophecy::Book do
  it "new book has title" do
    book = Prophecy::Book.new({ 'title' => 'Elder Lore' })
    book.title.should eql('Elder Lore')
  end
end
