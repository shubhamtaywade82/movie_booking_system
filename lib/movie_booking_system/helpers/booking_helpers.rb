# frozen_string_literal: true

module MovieBookingSystem
  module BookingHelpers
    def make_booking
      user_id = select_or_create_user
      return unless user_id

      show_id, seats = collect_booking_details
      return unless show_id && seats

      booking = @booking_service.create_booking(user_id, show_id, seats)
      success_message = "Booking created successfully. Seats: #{booking.booked_seats}"
      failure_message = "Booking failed. Please check availability and try again."
      message = booking ? success_message : failure_message
      puts message
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

    def collect_booking_details
      movie_id = select_movie
      return [nil, nil] unless movie_id

      show_id = select_show(movie_id)
      return [nil, nil] unless show_id

      seats = @prompt.ask("Enter the number of seats to book:", convert: :int)
      [show_id, seats]
    end

    def cancel_selected_booking(booking_id)
      if @booking_service.cancel_booking(booking_id)
        puts "Booking cancelled successfully."
      else
        puts "Cancellation failed. Please check the booking ID and try again."
      end
    end

    def find_user(user_id)
      @admin_service.list_users.find { |u| u.id == user_id }
    end

    def find_show(show_id, movie_id)
      @admin_service.list_shows_by_movie(movie_id).find { |s| s.id == show_id }
    end

    def find_movie(movie_id)
      @admin_service.list_movies.find { |m| m.id == movie_id }
    end
  end
end
