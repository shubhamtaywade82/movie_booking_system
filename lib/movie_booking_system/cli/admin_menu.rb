# frozen_string_literal: true

require_relative "movie"
require_relative "show"
require_relative "user"
require_relative "booking_list_menu"

module MovieBookingSystem
  class AdminMenu
    attr_reader :parent_menu

    def initialize(prompt, parent_menu)
      @prompt = prompt
      @parent_menu = parent_menu # Store the parent menu
    end

    def show
      loop do
        choices = {
          "Movie" => -> { MovieMenu.new(@prompt, self).show },
          "Show" => -> { ShowMenu.new(@prompt, self).show },
          "User" => -> { UserMenu.new(@prompt, self).show },
          "Booking" => -> { BookingListMenu.new(@prompt, self).list_bookings_by_movie },
          "Back" => -> { parent_menu.start }
        }

        action = @prompt.select("Admin Menu: Please choose an action:", choices, filter: true)
        action&.call
      rescue TTY::Reader::InputInterrupt
        break
      end
    end
  end
end
