# frozen_string_literal: true

RSpec.describe MovieBookingSystem::Association do # rubocop:disable RSpec/SpecFilePathFormat
  let(:headers_authors) { %i[id name genre] }
  let(:headers_books) { %i[id author_id title publication_date] }

  before do
    # Define Author and Book in the `before` block
    # to ensure they're within the same scope as the association tests.
    class Author < MovieBookingSystem::BaseModel # rubocop:disable Lint/ConstantDefinitionInBlock,RSpec/LeakyConstantDeclaration
      field :name, required: true, unique: true
      field :genre

      has_many :books

      csv_filename "spec/tmp/authors.csv"
    end

    class Book < MovieBookingSystem::BaseModel # rubocop:disable Lint/ConstantDefinitionInBlock,RSpec/LeakyConstantDeclaration
      field :author_id, type: :integer, required: true
      field :title, required: true
      field :publication_date, type: :date

      belongs_to :author

      csv_filename "spec/tmp/books.csv"
    end
  end

  after do
    FileUtils.rm_f("spec/tmp/authors.csv")
    FileUtils.rm_f("spec/tmp/books.csv")
  end

  describe ".belongs_to" do
    it "establishes a belongs_to association" do
      author = Author.create(name: "J.K. Rowling", genre: "Fantasy")
      book = Book.create(author_id: author.id, title: "Harry Potter and the Sorcerer's Stone",
                         publication_date: Date.parse("1997-06-26"))
      expect(book.author).to eq(author)
      expect(book.author_id).to eq(author.id)
    end
  end

  describe ".has_many" do
    it "establishes a has_many association" do
      author = Author.create(name: "J.K. Rowling", genre: "Fantasy")
      book1 = Book.create(author_id: author.id, title: "Harry Potter and the Sorcerer's Stone",
                          publication_date: Date.parse("1997-06-26"))
      book2 = Book.create(author_id: author.id, title: "Harry Potter and the Chamber of Secrets",
                          publication_date: Date.parse("1998-07-02"))
      expect(author.books).to eq([book1, book2])
    end
  end
end
