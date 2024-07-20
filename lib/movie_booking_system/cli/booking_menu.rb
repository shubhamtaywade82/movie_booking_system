# frozen_string_literal: true

require "tty-prompt"
require "tty-table"
require_relative "../helpers/booking_menu_helper"

module MovieBookingSystem
  # BookingMenu class handles the booking-related actions
  class BookingMenu
    include BookingMenuHelper

    attr_reader :parent_menu

    # Initializes the BookingMenu
    # @param prompt [TTY::Prompt] the TTY prompt instance
    # @param parent_menu [Object] the parent menu
    def initialize(prompt, parent_menu)
      @prompt = prompt
      @parent_menu = parent_menu
      @booking_service = BookingService.new
      @admin_service = AdminService.new
    end

    # Shows the booking menu
    def show
      loop do
        display_choices
        @prompt.select("Booking Menu: Please choose an action:", @choices, filter: true)
      rescue TTY::Reader::InputInterrupt
        break
      end
    end
  end
end
