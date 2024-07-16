# frozen_string_literal: true

module MovieBookingSystem
  class Show < CSVModel
    field :id
    field :movie_id, type: :integer, required: true
    field :show_time, type: :time, required: true
    field :total_capacity, type: :integer, required: true
    field :available_seats

    belongs_to :movie
    has_many :bookings

    def initialize(attributes = {})
      super
      initialize_available_seats
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

      booked_seats = if seat_count == 1
                       [seats.sample]
                     else
                       first_seat = seats.sample
                       first_index = seats.index(first_seat)
                       seats[first_index, seat_count]
                     end

      self.available_seats = (seats - booked_seats).join(",")
      save
      booked_seats
    end
  end
end
