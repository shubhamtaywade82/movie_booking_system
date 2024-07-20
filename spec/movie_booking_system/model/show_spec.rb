# frozen_string_literal: true

RSpec.describe MovieBookingSystem::Show do # rubocop:disable RSpec/SpecFilePathFormat
  let(:movie) { MovieBookingSystem::Movie.create(title: "Inception", genre: "Sci-Fi", duration: 148) }
  let(:attributes) { { movie_id: movie.id, show_time: Time.parse("20:00"), total_capacity: 100, available_seats: 100 } }

  describe ".create" do
    it "creates a new instance and saves it to the CSV" do
      show = described_class.create(attributes)
      expect(show).to be_a(described_class)
      expect(show[:id]).to eq(1)
      expect(described_class.all).to eq([show])
    end
  end

  describe ".find" do
    it "finds an instance by ID" do
      show = described_class.create(attributes)
      found_show = described_class.find(show[:id])
      expect(found_show).to eq(show)
    end

    it "returns nil if not found" do
      expect(described_class.find(999)).to be_nil
    end
  end

  describe ".all" do
    it "returns all instances" do
      described_class.create(attributes)
      described_class.create(movie_id: movie.id, show_time: Time.parse("22:00"), total_capacity: 80,
                             available_seats: 80)
      expect(described_class.all.size).to eq(2)
    end

    it "returns an empty array if there are no instances" do
      expect(described_class.all).to eq([])
    end
  end

  describe ".where" do
    before do
      described_class.create(attributes)
      described_class.create(movie_id: movie.id, show_time: Time.parse("22:00"), total_capacity: 80,
                             available_seats: 80)
    end

    it "filters instances based on conditions" do
      filtered_shows = described_class.where(movie_id: movie.id)
      expect(filtered_shows.size).to eq(2)
    end

    it "returns an empty array if no match" do
      filtered_shows = described_class.where(movie_id: 999)
      expect(filtered_shows).to eq([])
    end
  end

  describe "#save" do
    it "saves a new instance to the CSV" do
      show = described_class.new(attributes)
      expect(show.save).to be_truthy
      expect(described_class.all).to eq([show])
    end

    it "updates an existing instance in the CSV" do
      show = described_class.create(attributes)
      show[:total_capacity] = 200
      expect(show.save).to be_truthy
      expect(described_class.find(show[:id])[:total_capacity]).to eq(200)
    end
  end

  describe "#update" do
    it "updates attributes and saves" do
      show = described_class.create(attributes)
      show.update(total_capacity: 200)
      expect(show[:total_capacity]).to eq(200)
      expect(described_class.find(show[:id])[:total_capacity]).to eq(200)
    end
  end

  describe "#destroy" do
    it "deletes the instance from the CSV" do
      show = described_class.create(attributes)
      show.destroy
      expect(described_class.all).to eq([])
    end
  end
end
