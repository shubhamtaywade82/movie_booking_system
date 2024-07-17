# frozen_string_literal: true

require "tty-prompt"
require "tty-table"

module MovieBookingSystem
  class CLI # rubocop:disable Metrics/ClassLength
    SEPARATOR = "-----------------------------"

    def initialize
      @prompt = TTY::Prompt.new
      @admin_service = AdminService.new
      @booking_service = BookingService.new
      @last_action_was_separator = false
    end

    def start
      loop do
        main_menu
      end
    end

    private

    def main_menu
      choices = {
        "Admin Menu" => -> { admin_menu },
        "Booking Menu" => -> { booking_menu },
        "Exit" => -> { exit }
      }

      display_menu("Welcome to the Movie Booking System. Please choose an action:", choices)
    end

    def admin_menu # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      choices = {
        "List Movies" => -> { list_movies },
        "Add Movie" => -> { add_movie },
        "Update Movie" => -> { update_movie },
        "Delete Movie" => -> { delete_movie },
        "List Shows (Select Movie)" => -> { list_shows },
        "Add Show (Select Movie)" => -> { add_show },
        "Show Bookings for Movie Show" => -> { show_bookings },
        "Back" => -> { main_menu }
      }

      display_menu("Admin Menu: Please choose an action:", choices)
    end

    def booking_menu
      choices = {
        "Make Booking" => -> { make_booking },
        "Cancel Booking" => -> { cancel_booking },
        "Back" => -> { main_menu }
      }

      display_menu("Booking Menu: Please choose an action:", choices)
    end

    def display_menu(prompt_text, choices)
      print_separator
      @prompt.select(prompt_text, choices)
      @last_action_was_separator = false
    end

    def print_separator
      return if @last_action_was_separator

      puts SEPARATOR
      @last_action_was_separator = true
    end

    def list_movies
      movies = @admin_service.list_movies
      if movies.any?
        display_movies_table(movies)
      else
        puts "No movies available."
      end
      print_separator
    end

    def add_movie
      movie_attributes = collect_movie_attributes
      @admin_service.add_movie(movie_attributes)
      puts "Movie added successfully."
      print_separator
    end

    def update_movie
      movie_id = select_movie
      return unless movie_id

      movie_attributes = collect_movie_attributes
      @admin_service.update_movie(movie_id, movie_attributes)
      puts "Movie updated successfully."
      print_separator
    end

    def delete_movie
      movie_id = select_movie
      return unless movie_id

      @admin_service.delete_movie(movie_id)
      puts "Movie deleted successfully."
      print_separator
    end

    def list_shows
      movie_id = select_movie
      return unless movie_id

      shows = @admin_service.list_shows_by_movie(movie_id)
      if shows.any?
        display_shows_table(shows)
      else
        puts "No shows available for this movie."
      end
      print_separator
    end

    def add_show
      movie_id = select_movie
      return unless movie_id

      show_attributes = collect_show_attributes
      @admin_service.add_show(movie_id, show_attributes)
      puts "Show added successfully."
      print_separator
    end

    def show_bookings
      movie_id = select_movie
      return unless movie_id

      bookings_by_show = @admin_service.show_bookings_for_movie_show(movie_id)
      if bookings_by_show.any?
        display_bookings_by_show(bookings_by_show)
      else
        puts "No bookings available for shows of this movie."
      end
      print_separator
    end

    def make_booking
      user_id, show_id, seats = collect_booking_details
      return unless user_id && show_id && seats

      booking = @booking_service.create_booking(user_id, show_id, seats)
      puts booking ? "Booking created successfully. Seats: #{booking.booked_seats}" : "Booking failed. Please check availability and try again." # rubocop:disable Layout/LineLength
      print_separator
    end

    def cancel_booking
      bookings = @booking_service.list_bookings
      if bookings.any?
        booking_id = select_booking(bookings)
        cancel_selected_booking(booking_id)
      else
        puts "No bookings available to cancel."
      end
      print_separator
    end

    def select_movie
      movies = @admin_service.list_movies
      return @prompt.select("Select a movie from the list:", format_movies_for_prompt(movies)) if movies.any?

      puts "No movies available."
      print_separator
      nil
    end

    def select_show(movie_id)
      shows = @admin_service.list_shows_by_movie(movie_id)
      return @prompt.select("Select a show from the list:", format_shows_for_prompt(shows)) if shows.any?

      puts "No shows available for this movie."
      print_separator
      nil
    end

    def collect_movie_attributes
      title = @prompt.ask("Enter the movie title:")
      genre = @prompt.ask("Enter the movie genre:")
      duration = @prompt.ask("Enter the movie duration (in minutes):", convert: :int)
      { title: title, genre: genre, duration: duration }
    end

    def collect_show_attributes
      show_time = @prompt.ask("Enter the show time (HH:MM format):")
      unless valid_time_format?(show_time)
        puts "Invalid time format. Please enter the time in HH:MM format."
        return
      end
      total_capacity = @prompt.ask("Enter the total capacity for the show:", convert: :int)
      { show_time: show_time, total_capacity: total_capacity }
    end

    def collect_booking_details
      user_id = @prompt.ask("Enter your user ID:", convert: :int)
      movie_id = select_movie
      return [nil, nil, nil] unless movie_id

      show_id = select_show(movie_id)
      return [nil, nil, nil] unless show_id

      seats = @prompt.ask("Enter the number of seats to book:", convert: :int)
      [user_id, show_id, seats]
    end

    def select_booking(bookings)
      @prompt.select(
        "Select a booking to cancel:",
        bookings.map { |b| { name: "Booking ##{b.id}: Show ID #{b.show_id}, Seats #{b.seats}", value: b.id } }
      )
    end

    def cancel_selected_booking(booking_id)
      if @booking_service.cancel_booking(booking_id)
        puts "Booking cancelled successfully."
      else
        puts "Cancellation failed. Please check the booking ID and try again."
      end
    end

    def display_movies_table(movies)
      table = TTY::Table.new(header: %w[ID Title Genre Duration], rows: movies.map do |m|
                                                                          [m.id, m.title, m.genre, m.duration]
                                                                        end)
      puts table.render(:unicode)
    end

    def display_shows_table(shows)
      table = TTY::Table.new(header: ["ID", "Movie ID", "Show Time", "Capacity", "Available Seats"],
                             rows: shows.map do |s|
                                     [s.id, s.movie_id, s.show_time, s.total_capacity, s.available_seats]
                                   end)
      puts table.render(:unicode)
    end

    def display_bookings_by_show(bookings_by_show)
      bookings_by_show.each do |show, bookings|
        table = TTY::Table.new(header: ["Show ID", "Show Time", "Total Capacity", "Available Seats"],
                               rows: [[show.id, show.show_time, show.total_capacity, show.available_seats]])
        puts table.render(:unicode)
        bookings.each { |booking| display_booking_details(booking) }
      end
    end

    def display_booking_details(booking)
      table = TTY::Table.new(header: ["Booking ID", "User ID", "Seats", "Booked Seats"],
                             rows: [[booking.id, booking.user_id, booking.seats, booking.booked_seats]])
      puts table.render(:unicode)
    end

    def format_movies_for_prompt(movies)
      movies.map { |m| { name: "#{m.title} (#{m.id})", value: m.id } }
    end

    def format_shows_for_prompt(shows)
      shows.map { |s| { name: "#{s.show_time} (#{s.id})", value: s.id } }
    end

    def valid_time_format?(time_string)
      !!(time_string =~ /^([01]\d|2[0-3]):([0-5]\d)$/)
    end
  end
end
