# frozen_string_literal: true

require "tty-prompt"
require "tty-table"
require_relative "booking_list_menu"

module MovieBookingSystem
  class BookingMenu
    attr_reader :parent_menu

    def initialize(prompt, parent_menu)
      @prompt = prompt
      @parent_menu = parent_menu
      @booking_service = BookingService.new
      @admin_service = AdminService.new
    end

    def show
      loop do
        choices = {
          "Make Booking" => -> { make_booking },
          "Cancel Booking" => -> { cancel_booking },
          "List All Bookings" => -> { list_all_bookings },
          "Back" => -> { parent_menu.start }
        }

        @prompt.select("Booking Menu: Please choose an action:", choices, filter: true)
      rescue TTY::Reader::InputInterrupt
        break
      end
    end

    private

    def make_booking
      user_id = select_or_create_user
      return unless user_id

      show_id, seats = collect_booking_details
      return unless show_id && seats

      booking = @booking_service.create_booking(user_id, show_id, seats)
      puts booking ? "Booking created successfully. Seats: #{booking.booked_seats}" : "Booking failed. Please check availability and try again."
    end

    def cancel_booking
      bookings = @booking_service.list_bookings
      if bookings.any?
        booking_id = select_booking(bookings)
        cancel_selected_booking(booking_id)
      else
        puts "No bookings available to cancel."
      end
    end

    def list_all_bookings
      bookings = @booking_service.list_bookings
      if bookings.any?
        bookings.each { |booking| display_booking_details(booking) }
      else
        puts "No bookings available."
      end
    end

    def select_or_create_user
      choices = {
        "Choose an existing user" => -> { select_user },
        "Create a new user" => -> { create_user },
        "Back" => -> { show }
      }

      @prompt.select("Do you want to:", choices, filter: true)
    end

    def select_user
      users = @admin_service.list_users
      if users.any?
        return @prompt.select("Select a user from the list: (Note: press ctrl + c to go back)",
                              format_users_for_prompt(users))
      end

      puts "No users available."
      nil
    end

    def create_user
      user_name = @prompt.ask("Enter the user's name:")
      user = @admin_service.create_user(name: user_name)
      puts "User created successfully." if user
      user&.id
    end

    def collect_booking_details
      movie_id = select_movie
      return [nil, nil] unless movie_id

      show_id = select_show(movie_id)
      return [nil, nil] unless show_id

      seats = @prompt.ask("Enter the number of seats to book:", convert: :int)
      [show_id, seats]
    end

    def select_movie
      movies = @admin_service.list_movies
      if movies.any?
        return @prompt.select("Select a movie from the list:", format_movies_for_prompt(movies), filter: true)
      end

      puts "No movies available."
      nil
    end

    def select_show(movie_id)
      shows = @admin_service.list_shows_by_movie(movie_id)
      return @prompt.select("Select a show from the list:", format_shows_for_prompt(shows), filter: true) if shows.any?

      puts "No shows available for this movie."
      nil
    end

    def select_booking(bookings)
      @prompt.select(
        "Select a booking to cancel:",
        bookings.map { |b| { name: "Booking ##{b.id}: Show ID #{b.show_id}, Seats #{b.seats}", value: b.id } },
        filter: true
      )
    end

    def cancel_selected_booking(booking_id)
      if @booking_service.cancel_booking(booking_id)
        puts "Booking cancelled successfully."
      else
        puts "Cancellation failed. Please check the booking ID and try again."
      end
    end

    def display_booking_details(booking)
      user = @admin_service.list_users.find { |u| u.id == booking.user_id }
      show = @admin_service.list_shows_by_movie(booking.show_id).find { |s| s.id == booking.show_id }
      movie = @admin_service.list_movies.find { |m| m.id == show.movie_id }

      table = TTY::Table.new(header: ["Booking ID", "User Name", "Movie Title", "Show Time", "Seats", "Booked Seats"],
                             rows: [[booking.id, user.name, movie.title, show.show_time, booking.seats, booking.booked_seats]])
      puts table.render(:unicode)
    end

    def format_movies_for_prompt(movies)
      movies.map { |m| { name: "#{m.title} (#{m.id})", value: m.id } }
    end

    def format_shows_for_prompt(shows)
      shows.map { |s| { name: "#{s.show_time} (#{s.id})", value: s.id } }
    end

    def format_users_for_prompt(users)
      users.map { |u| { name: "#{u.name} (#{u.id})", value: u.id } }
    end
  end
end
