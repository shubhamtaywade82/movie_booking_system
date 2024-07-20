# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:all) do
    MovieBookingSystem::Booking.csv_filename("spec/tmp/bookings.csv")
    MovieBookingSystem::User.csv_filename("spec/tmp/users.csv")
    MovieBookingSystem::Movie.csv_filename("spec/tmp/movies.csv")
    MovieBookingSystem::Show.csv_filename("spec/tmp/shows.csv")
  end
end
