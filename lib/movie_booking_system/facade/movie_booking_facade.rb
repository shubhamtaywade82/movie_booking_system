# frozen_string_literal: true

module MovieBookingSystem
  class MovieBookingFacade
    def initialize
      @booking_service = BookingService.new
    end

    def make_booking(user_id, show_id, seats)
      @booking_service.create_booking(user_id, show_id, seats)
    end

    def cancel_booking(booking_id)
      @booking_service.cancel_booking(booking_id)
    end

    def list_bookings
      @booking_service.list_bookings
    end
  end
end
