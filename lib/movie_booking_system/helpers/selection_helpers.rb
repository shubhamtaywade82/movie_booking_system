# frozen_string_literal: true

module MovieBookingSystem
  module SelectionHelpers
    def select_or_create_user
      choices = {
        "Choose an existing user" => -> { select_user },
        "Create a new user" => -> { create_user },
        "Back" => -> { show }
      }

      @prompt.select("Do you want to:", choices, filter: true)
    end

    def select_user
      users = @admin_service.list_users
      if users.any?
        return @prompt.select("Select a user from the list: (Note: press ctrl + c to go back)",
                              format_users_for_prompt(users))
      end

      puts "No users available."
      nil
    end

    def create_user
      user_name = @prompt.ask("Enter the user's name:")
      user = @admin_service.create_user(name: user_name)
      puts "User created successfully." if user
      user&.id
    end

    def select_movie
      movies = @admin_service.list_movies
      if movies.any?
        return @prompt.select("Select a movie from the list:", format_movies_for_prompt(movies), filter: true)
      end

      puts "No movies available."
      nil
    end

    def select_show(movie_id)
      shows = @admin_service.list_shows_by_movie(movie_id)
      return @prompt.select("Select a show from the list:", format_shows_for_prompt(shows), filter: true) if shows.any?

      puts "No shows available for this movie."
      nil
    end

    def select_booking(bookings)
      @prompt.select(
        "Select a booking to cancel:",
        bookings.map { |b| { name: "Booking ##{b.id}: Show ID #{b.show_id}, Seats #{b.seats}", value: b.id } },
        filter: true
      )
    end
  end
end
