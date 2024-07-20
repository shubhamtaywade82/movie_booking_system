# frozen_string_literal: true

module MovieBookingSystem
  module DisplayHelpers
    def display_choices
      @choices = {
        "Make Booking" => -> { make_booking },
        "Cancel Booking" => -> { cancel_booking },
        "List All Bookings" => -> { list_all_bookings },
        "Back" => -> { parent_menu.start }
      }
    end

    def display_booking_details(booking)
      user = find_user(booking.user_id)
      show = find_show(booking.show_id, booking.show.movie_id)
      movie = find_movie(show.movie_id)

      rows = create_booking_table_rows(booking, user, movie, show)
      table = TTY::Table.new(header: ["Booking ID", "User Name", "Movie Title", "Show Time", "Seats", "Booked Seats"],
                             rows: rows)
      puts table.render(:unicode)
    end

    def create_booking_table_rows(booking, user, movie, show)
      [[booking.id, user.name, movie.title, show.show_time, booking.seats, booking.booked_seats]]
    end

    def format_movies_for_prompt(movies)
      movies.map { |m| { name: "#{m.title} (#{m.id})", value: m.id } }
    end

    def format_shows_for_prompt(shows)
      shows.map { |s| { name: "#{s.show_time} (#{s.id})", value: s.id } }
    end

    def format_users_for_prompt(users)
      users.map { |u| { name: "#{u.name} (#{u.id})", value: u.id } }
    end
  end
end
