# frozen_string_literal: true

module MovieBookingSystem
  class User < CSVModel
    field :id
    field :name, required: true
    field :email, required: true, unique: true

    has_many :bookings
  end
end
