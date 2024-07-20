# frozen_string_literal: true

module MovieBookingSystem
  class User < BaseModel
    field :name, required: true

    has_many :bookings
  end
end
