# frozen_string_literal: true

require "tty-prompt"
require "tty-table"

module MovieBookingSystem
  # BookingListMenu class handles listing bookings by movie
  class BookingListMenu
    attr_reader :parent_menu

    # Initializes the BookingListMenu
    # @param prompt [TTY::Prompt] the TTY prompt instance
    # @param parent_menu [Object] the parent menu
    def initialize(prompt, parent_menu)
      @prompt = prompt
      @parent_menu = parent_menu
      @admin_service = AdminService.new
      @booking_service = BookingService.new
    end

    # Lists bookings by movie
    def list_bookings_by_movie
      loop do
        movie_id = select_movie
        return unless movie_id

        display_bookings(movie_id)
      rescue TTY::Reader::InputInterrupt
        break
      end
    end

    private

    def display_bookings(movie_id)
      bookings_by_show = @admin_service.show_bookings_for_movie_show(movie_id)
      if bookings_by_show.any?
        display_bookings_by_show(bookings_by_show)
      else
        puts "No bookings available for shows of this movie."
      end
    end

    def select_movie
      movies = @admin_service.list_movies
      return @prompt.select("Select a movie from the list:", format_movies_for_prompt(movies)) if movies.any?

      puts "No movies available."
      nil
    end

    def format_movies_for_prompt(movies)
      movies.map { |m| { name: "#{m.title} (#{m.id})", value: m.id } }
    end

    def display_bookings_by_show(bookings_by_show)
      bookings_by_show.each do |show, bookings|
        display_show_details(show)
        bookings.each { |booking| display_booking_details(booking) }
      end
    end

    def display_show_details(show)
      table = TTY::Table.new(header: ["Show ID", "Show Time", "Total Capacity", "Available Seats"],
                             rows: [[show.id, show.show_time, show.total_capacity, show.available_seats]])
      puts table.render(:unicode)
    end

    def display_booking_details(booking)
      table = TTY::Table.new(header: ["Booking ID", "User ID", "Seats", "Booked Seats"],
                             rows: [[booking.id, booking.user_id, booking.seats, booking.booked_seats]])
      puts table.render(:unicode)
    end
  end
end
