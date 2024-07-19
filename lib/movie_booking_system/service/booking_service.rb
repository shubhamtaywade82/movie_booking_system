# frozen_string_literal: true

module MovieBookingSystem
  class BookingService
    def initialize
      @show_class = Show
      @booking_class = Booking
    end

    def create_booking(user_id, show_id, seat_count)
      show = @show_class.find(show_id)
      return nil unless show

      booked_seats = show.book_seats(seat_count)
      return nil unless booked_seats

      @booking_class.create(user_id: user_id, show_id: show_id, seats: seat_count, booked_seats: booked_seats.join(","))
    end

    def cancel_booking(booking_id)
      booking = @booking_class.find(booking_id)
      return nil unless booking

      show = @show_class.find(booking.show_id)
      return nil unless show

      show.update(available_seats: (show.available_seats.split(",") + booking.booked_seats.split(",")).join(","))
      booking.destroy
    end

    def list_bookings
      @booking_class.all
    end
  end
end
