# frozen_string_literal: true

require "pry"
require_relative "movie_booking_system/version"
require_relative "movie_booking_system/ext/string"
require_relative "movie_booking_system/concerns/association"
require_relative "movie_booking_system/concerns/validation"
require_relative "movie_booking_system/orm/csv_handler"
require_relative "movie_booking_system/orm/csv_model"
require_relative "movie_booking_system/model/movie"
require_relative "movie_booking_system/model/show"
require_relative "movie_booking_system/model/booking"
require_relative "movie_booking_system/model/user"
require_relative "movie_booking_system/cli/main"
require_relative "movie_booking_system/service/admin_service"
require_relative "movie_booking_system/service/booking_service"

module MovieBookingSystem
  class Error < StandardError; end
  # Your code goes here...
end
