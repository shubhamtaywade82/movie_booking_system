# frozen_string_literal: true

require "pry"
require_relative "movie_booking_system/version"
require_relative "movie_booking_system/ext/string"
require_relative "movie_booking_system/concerns/validation"
require_relative "movie_booking_system/orm/csv_handler"
require_relative "movie_booking_system/orm/csv_model"

module MovieBookingSystem
  class Error < StandardError; end
  # Your code goes here...
end
