# frozen_string_literal: true

require "tty-prompt"

module MovieBookingSystem
  class CLI
    def initialize
      @prompt = TTY::Prompt.new
      @admin_service = AdminService.new
      @booking_service = BookingService.new
    end

    def start
      loop do
        choices = {
          "Admin Menu" => -> { admin_menu },
          "Booking Menu" => -> { booking_menu },
          "Exit" => -> { exit }
        }

        @prompt.select("Choose an action:", choices)
      end
    end

    private

    def admin_menu
      choices = {
        "List Movies" => -> { list_movies },
        "Add Movie" => -> { add_movie },
        "Update Movie" => -> { update_movie },
        "Delete Movie" => -> { delete_movie },
        "List Shows (Select Movie)" => -> { list_shows },
        "Add Show (Select Movie)" => -> { add_show },
        "Show Bookings for Movie Show" => -> { show_bookings },
        "Back" => -> { start }
      }

      @prompt.select("Admin Menu:", choices)
    end

    def booking_menu
      choices = {
        "Make Booking" => -> { make_booking },
        "Cancel Booking" => -> { cancel_booking },
        "Back" => -> { start }
      }

      @prompt.select("Booking Menu:", choices)
    end

    def list_movies
      movies = @admin_service.list_movies
      if movies.any?
        movies.each { |movie| puts "#{movie.id}: #{movie.title} (#{movie.genre}) - Duration: #{movie.duration} mins" }
      else
        puts "No movies available."
      end
    end

    def add_movie
      title = @prompt.ask("Title:")
      genre = @prompt.ask("Genre:")
      duration = @prompt.ask("Duration (mins):", convert: :int)
      @admin_service.add_movie(title: title, genre: genre, duration: duration)
      puts "Movie added successfully."
    end

    def update_movie
      movie_id = select_movie
      return unless movie_id

      title = @prompt.ask("Title:")
      genre = @prompt.ask("Genre:")
      duration = @prompt.ask("Duration (mins):", convert: :int)
      @admin_service.update_movie(movie_id, title: title, genre: genre, duration: duration)
      puts "Movie updated successfully."
    end

    def delete_movie
      movie_id = select_movie
      return unless movie_id

      @admin_service.delete_movie(movie_id)
      puts "Movie deleted successfully."
    end

    def list_shows
      movie_id = select_movie
      return unless movie_id

      shows = @admin_service.list_shows_by_movie(movie_id)
      if shows.any?
        shows.each do |show|
          puts "#{show.id}: Movie ID #{show.movie_id} at #{show.show_time} - Capacity: #{show.total_capacity}, Available Seats: #{show.available_seats}"
        end
      else
        puts "No shows available for this movie."
      end
    end

    def add_show
      movie_id = select_movie
      return unless movie_id

      show_time = @prompt.ask("Show Time (HH:MM):", convert: :time)
      total_capacity = @prompt.ask("Total Capacity:", convert: :int)
      @admin_service.add_show(movie_id, show_time: show_time, total_capacity: total_capacity)
      puts "Show added successfully."
    end

    def show_bookings
      movie_id = select_movie
      return unless movie_id

      bookings = @admin_service.show_bookings_for_movie_show(movie_id)
      bookings.each do |show, bookings|
        puts "Show ID: #{show.id}, Show Time: #{show.show_time}, Total Capacity: #{show.total_capacity}, Available Seats: #{show.available_seats}"
        bookings.each do |booking|
          puts "  Booking ID: #{booking.id}, User ID: #{booking.user_id}, Seats: #{booking.seats}, Booked Seats: #{booking.booked_seats}"
        end
      end
    end

    def make_booking
      user_id = @prompt.ask("User ID:", convert: :int)
      movie_id = select_movie
      return unless movie_id

      show_id = select_show(movie_id)
      return unless show_id

      seats = @prompt.ask("Number of seats:", convert: :int)
      booking = @booking_service.create_booking(user_id, show_id, seats)
      if booking
        puts "Booking created successfully. Seats: #{booking.booked_seats}"
      else
        puts "Booking failed. Please check availability and try again."
      end
    end

    def cancel_booking
      bookings = @booking_service.list_bookings
      if bookings.any?
        booking_id = @prompt.select(
          "Select a booking to cancel:",
          bookings.map do |b|
            { name: "Booking ##{b.id}: Show ID #{b.show_id}, Seats #{b.seats}", value: b.id }
          end
        )
        if @booking_service.cancel_booking(booking_id)
          puts "Booking cancelled successfully."
        else
          puts "Cancellation failed. Please check the booking ID and try again."
        end
      else
        puts "No bookings available to cancel."
      end
    end

    def select_movie
      movies = @admin_service.list_movies
      if movies.any?
        @prompt.select("Select a movie:", movies.map { |m| { name: "#{m.title} (#{m.id})", value: m.id } })
      else
        puts "No movies available."
        nil
      end
    end

    def select_show(movie_id)
      shows = @admin_service.list_shows_by_movie(movie_id)
      if shows.any?
        @prompt.select("Select a show:", shows.map { |s| { name: "#{s.show_time} (#{s.id})", value: s.id } })
      else
        puts "No shows available for this movie."
        nil
      end
    end
  end
end
