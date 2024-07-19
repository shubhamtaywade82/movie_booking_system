# frozen_string_literal: true

module MovieBookingSystem
  class User < CSVModel
    field :name, required: true

    has_many :bookings
  end
end
