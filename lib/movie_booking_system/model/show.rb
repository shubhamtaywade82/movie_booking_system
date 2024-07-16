# frozen_string_literal: true

module MovieBookingSystem
  class Show < CSVModel
    field :id
    field :movie_id, type: :integer, required: true
    field :show_time, type: :time, required: true
    field :total_capacity, type: :integer, required: true
    field :available_seats, type: :integer, required: true

    belongs_to :movie
    has_many :bookings
  end
end
