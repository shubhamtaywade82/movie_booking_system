# frozen_string_literal: true

RSpec.describe MovieBookingSystem::Movie do # rubocop:disable RSpec/SpecFilePathFormat
  let(:attributes) { { title: "Inception", genre: "Sci-Fi", duration: 148 } }

  describe ".create" do
    it "creates a new instance and saves it to the CSV" do
      movie = described_class.create(attributes)
      expect(movie).to be_a(described_class)
      expect(movie[:id]).to eq(1)
      expect(described_class.all).to eq([movie])
    end
  end

  describe ".find" do
    it "finds an instance by ID" do
      movie = described_class.create(attributes)
      found_movie = described_class.find(movie[:id])
      expect(found_movie).to eq(movie)
    end

    it "returns nil if not found" do
      expect(described_class.find(999)).to be_nil
    end
  end

  describe ".all" do
    it "returns all instances" do
      described_class.create(attributes)
      described_class.create(title: "The Matrix", genre: "Sci-Fi", duration: 136)
      expect(described_class.all.size).to eq(2)
    end

    it "returns an empty array if there are no instances" do
      expect(described_class.all).to eq([])
    end
  end

  describe ".where" do
    before do
      described_class.create(attributes)
      described_class.create(title: "The Matrix", genre: "Sci-Fi", duration: 136)
    end

    it "filters instances based on conditions" do
      filtered_movies = described_class.where(genre: "Sci-Fi")
      expect(filtered_movies.size).to eq(2)
    end

    it "returns an empty array if no match" do
      filtered_movies = described_class.where(genre: "Comedy")
      expect(filtered_movies).to eq([])
    end
  end

  describe "#save" do
    it "saves a new instance to the CSV" do
      movie = described_class.new(attributes)
      expect(movie.save).to be_truthy
      expect(described_class.all).to eq([movie])
    end

    it "updates an existing instance in the CSV" do
      movie = described_class.create(attributes)
      movie[:title] = "Updated Title"
      expect(movie.save).to be_truthy
      expect(described_class.find(movie[:id])[:title]).to eq("Updated Title")
    end
  end

  describe "#update" do
    it "updates attributes and saves" do
      movie = described_class.create(attributes)
      movie.update(title: "Updated Title")
      expect(movie[:title]).to eq("Updated Title")
      expect(described_class.find(movie[:id])[:title]).to eq("Updated Title")
    end
  end

  describe "#destroy" do
    it "deletes the instance from the CSV" do
      movie = described_class.create(attributes)
      movie.destroy
      expect(described_class.all).to eq([])
    end
  end
end
