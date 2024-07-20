# frozen_string_literal: true

require_relative "movie"
require_relative "show"
require_relative "user"
require_relative "booking_list_menu"

module MovieBookingSystem
  # AdminMenu class handles the admin-related actions
  class AdminMenu
    attr_reader :parent_menu

    # Initializes the AdminMenu
    # @param prompt [TTY::Prompt] the TTY prompt instance
    # @param parent_menu [Object] the parent menu
    def initialize(prompt, parent_menu)
      @prompt = prompt
      @parent_menu = parent_menu
    end

    # Shows the admin menu
    def show
      loop do
        display_choices
        action = @prompt.select("Admin Menu: Please choose an action:", choices, filter: true)
        action&.call
      rescue TTY::Reader::InputInterrupt
        break
      end
    end

    private

    def display_choices
      @choices = {
        Movie: -> { MovieMenu.new(@prompt, self).show },
        Show: -> { ShowMenu.new(@prompt, self).show },
        User: -> { UserMenu.new(@prompt, self).show },
        Booking: -> { BookingListMenu.new(@prompt, self).list_bookings_by_movie },
        Back: -> { parent_menu.start }
      }
    end

    attr_reader :choices
  end
end
