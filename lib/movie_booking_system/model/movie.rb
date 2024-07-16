# frozen_string_literal: true

module MovieBookingSystem
  class Movie < CSVModel
    field :id
    field :title, required: true, unique: true
    field :genre
    field :duration, type: :integer

    has_many :shows
  end
end
