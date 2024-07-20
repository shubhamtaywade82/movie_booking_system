# frozen_string_literal: true

require_relative "display_helpers"
require_relative "selection_helpers"
require_relative "booking_helpers"

module MovieBookingSystem
  module BookingMenuHelper
    include DisplayHelpers
    include SelectionHelpers
    include BookingHelpers
  end
end
