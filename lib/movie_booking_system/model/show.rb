# frozen_string_literal: true

module MovieBookingSystem
  class Show < BaseModel
    field :movie_id, type: :integer, required: true
    field :show_time, type: :time, required: true
    field :total_capacity, type: :integer, required: true
    field :available_seats

    belongs_to :movie
    has_many :bookings

    def initialize(attributes = {})
      super
      initialize_available_seats if attributes[:available_seats].nil?
    end

    def initialize_available_seats
      rows = ("A".."Z").to_a
      seats = []
      total_capacity.times do |i|
        row = rows[i / 10]
        seat_number = (i % 10) + 1
        seats << "#{row}#{seat_number}"
      end
      self.available_seats = seats.join(",")
    end

    def book_seats(seat_count)
      seats = available_seats.split(",")
      return nil if seats.size < seat_count

      booked_seats = book_seats_sample(seat_count, seats)

      self.available_seats = (seats - booked_seats).join(",")
      save
      booked_seats
    end

    def cancel_seats(booked_seats)
      current_seats = available_seats.split(",")
      updated_seats = (current_seats + booked_seats).uniq
      self.available_seats = updated_seats.join(",")
      save
    end

    private

    def book_seats_sample(seat_count, seats)
      if seat_count == 1
        [seats.sample]
      else
        first_seat = seats.sample
        first_index = seats.index(first_seat)
        seats[first_index, seat_count]
      end
    end
  end
end
