# frozen_string_literal: true

require "faker"
require "movie_booking_system"

def generate_movies(num_movies)
  num_movies.times do
    MovieBookingSystem::Movie.create(
      title: Faker::Movie.title,
      genre: Faker::Book.genre,
      duration: Faker::Number.between(from: 90, to: 180),
      show_time: Faker::Time.between_dates(from: Date.today, to: Date.today + 1, period: :evening)
    )
  end
end

def generate_shows(num_shows_per_movie)
  MovieBookingSystem::Movie.all.each do |movie|
    num_shows_per_movie.times do
      MovieBookingSystem::Show.create(
        movie_id: movie.id,
        show_time: Faker::Time.between_dates(from: Date.today, to: Date.today + 1, period: :evening),
        total_capacity: Faker::Number.between(from: 5, to: 20)
      )
    end
  end
end

def generate_users(num_users)
  num_users.times do
    MovieBookingSystem::User.create(
      name: Faker::Name.name
    )
  end
end

def generate_bookings(num_bookings) # rubocop:disable Metrics/MethodLength
  num_bookings.times do
    user = MovieBookingSystem::User.all.sample
    show = MovieBookingSystem::Show.all.sample
    seats = Faker::Number.between(from: 1, to: 5)

    booked_seats = show.book_seats(seats)
    if booked_seats.nil?
      puts "Not enough seats available for Show ID: #{show.id} for #{seats} seats, Skipping booking"
      next
    end
    MovieBookingSystem::Booking.create(
      user_id: user.id,
      show_id: show.id,
      seats: seats,
      booked_seats: booked_seats.join(",")
    )
  end
end

# Seed the data
# generate_movies(10) # Create 10 movies
# generate_shows(2) # Create 2 shows per movie
# generate_users(5) # Create 20 users
