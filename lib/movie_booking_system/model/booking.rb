# frozen_string_literal: true

module MovieBookingSystem
  class Booking < CSVModel
    field :user_id, type: :integer, required: true
    field :show_id, type: :integer, required: true
    field :seats, type: :integer, required: true
    field :booked_seats, required: true

    belongs_to :user
    belongs_to :show
  end
end
