# frozen_string_literal: true

require "tty-prompt"
require "tty-table"
require_relative "cli/admin_menu"
require_relative "cli/booking_menu"

module MovieBookingSystem
  class CLI
    SEPARATOR = "-----------------------------"

    def initialize
      @prompt = TTY::Prompt.new
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
        "Admin Menu" => -> { AdminMenu.new(@prompt, self).show },
        "Booking Menu" => -> { BookingMenu.new(@prompt, self).show },
        "Exit" => -> { exit }
      }

      action = @prompt.select("Welcome to the Movie Booking System. Please choose an action:", choices, filter: true)
      action&.call
    rescue TTY::Reader::InputInterrupt
      exit
    end

    def display_menu(prompt_text, choices)
      print_separator
      action = @prompt.select(prompt_text, choices, filter: true)
      action&.call
      @last_action_was_separator = false
    rescue TTY::Reader::InputInterrupt
      exit
    end

    def print_separator
      return if @last_action_was_separator

      puts SEPARATOR
      @last_action_was_separator = true
    end
  end
end
