# frozen_string_literal: true

RSpec.describe MovieBookingSystem::Booking do # rubocop:disable RSpec/SpecFilePathFormat
  let(:user) { MovieBookingSystem::User.create(name: "John Doe") }
  let(:movie) { MovieBookingSystem::Movie.create(title: "Inception", genre: "Sci-Fi", duration: 148) }
  let(:show) do
    MovieBookingSystem::Show.create(movie_id: movie.id, show_time: Time.parse("20:00"), total_capacity: 21)
  end
  let(:attributes) { { user_id: user.id, show_id: show.id, seats: 2, booked_seats: "A1,A2" } }

  describe ".create" do
    it "creates a new instance and saves it to the CSV" do
      booking = described_class.create(attributes)
      expect(booking).to be_a(described_class)
      expect(booking[:id]).to eq(1)
      expect(described_class.all).to eq([booking])
    end
  end

  describe ".find" do
    it "finds an instance by ID" do
      booking = described_class.create(attributes)
      found_booking = described_class.find(booking[:id])
      expect(found_booking).to eq(booking)
    end

    it "returns nil if not found" do
      expect(described_class.find(999)).to be_nil
    end
  end

  describe ".all" do
    it "returns all instances" do
      described_class.create(attributes)
      described_class.create(user_id: user.id, show_id: show.id, seats: 4, booked_seats: "B1,B2,B3,B4")
      expect(described_class.all.size).to eq(2)
    end

    it "returns an empty array if there are no instances" do
      expect(described_class.all).to eq([])
    end
  end

  describe ".where" do
    before do
      described_class.create(attributes)
      described_class.create(user_id: user.id, show_id: show.id, seats: 4, booked_seats: "B1,B2,B3,B4")
    end

    it "filters instances based on conditions" do
      filtered_bookings = described_class.where(user_id: user.id)
      expect(filtered_bookings.size).to eq(2)
    end

    it "returns an empty array if no match" do
      filtered_bookings = described_class.where(user_id: 999)
      expect(filtered_bookings).to eq([])
    end
  end

  describe "#save" do
    it "saves a new instance to the CSV" do
      booking = described_class.new(attributes)
      expect(booking.save).to be_truthy
      expect(described_class.all).to eq([booking])
    end

    it "updates an existing instance in the CSV" do
      booking = described_class.create(attributes)
      booking[:seats] = 3
      expect(booking.save).to be_truthy
      expect(described_class.find(booking[:id])[:seats]).to eq(3)
    end
  end

  describe "#update" do
    it "updates attributes and saves" do
      booking = described_class.create(attributes)
      booking.update(seats: 3)
      expect(booking[:seats]).to eq(3)
      expect(described_class.find(booking[:id])[:seats]).to eq(3)
    end
  end

  describe "#destroy" do
    it "deletes the instance from the CSV" do
      booking = described_class.create(attributes)
      booking.destroy
      expect(described_class.all).to eq([])
    end
  end

  describe "validations" do
    it "validates presence of user_id" do
      invalid_attributes = attributes.merge(user_id: nil)
      booking = described_class.new(invalid_attributes)
      expect(booking).not_to be_valid
      expect(booking.errors).to include("user_id cannot be blank")
    end

    it "validates presence of show_id" do
      invalid_attributes = attributes.merge(show_id: nil)
      booking = described_class.new(invalid_attributes)
      expect(booking).not_to be_valid
      expect(booking.errors).to include("show_id cannot be blank")
    end

    it "validates presence of seats" do
      invalid_attributes = attributes.merge(seats: nil)
      booking = described_class.new(invalid_attributes)
      expect(booking).not_to be_valid
      expect(booking.errors).to include("seats cannot be blank")
    end

    it "validates presence of booked_seats" do
      invalid_attributes = attributes.merge(booked_seats: nil)
      booking = described_class.new(invalid_attributes)
      expect(booking).not_to be_valid
      expect(booking.errors).to include("booked_seats cannot be blank")
    end

    it "validates numericality of seats" do
      invalid_attributes = attributes.merge(seats: "two")
      booking = described_class.new(invalid_attributes)
      expect(booking).not_to be_valid
      expect(booking.errors).to include("seats must be an integer")
    end
  end
end
