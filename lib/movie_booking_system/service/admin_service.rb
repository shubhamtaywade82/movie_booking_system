# frozen_string_literal: true

module MovieBookingSystem
  class AdminService
    def initialize
      @movie_class = Movie
      @show_class = Show
      @user_class = User
      @booking_class = Booking
    end

    # Movie operations
    def add_movie(attributes)
      @movie_class.create(attributes)
    end

    def list_movies
      @movie_class.all
    end

    def update_movie(id, attributes)
      movie = @movie_class.find(id)
      movie&.update(attributes)
    end

    def delete_movie(id)
      movie = @movie_class.find(id)
      movie&.destroy
    end

    # Show operations
    def add_show(movie_id, attributes)
      attributes[:movie_id] = movie_id
      @show_class.create(attributes)
    end

    def list_shows_by_movie(movie_id)
      @show_class.where(movie_id: movie_id)
    end

    def update_show(id, attributes)
      show = @show_class.find(id)
      show&.update(attributes)
    end

    def delete_show(id)
      show = @show_class.find(id)
      show&.destroy
    end

    # User operations
    def create_user(attributes)
      @user_class.create(attributes)
    end

    def list_users
      @user_class.all
    end

    def update_user(id, attributes)
      user = @user_class.find(id)
      user&.update(attributes)
    end

    def delete_user(id)
      user = @user_class.find(id)
      user&.destroy
    end

    # Booking operations
    def show_bookings_for_movie_show(movie_id)
      shows = list_shows_by_movie(movie_id)
      shows.each_with_object({}) do |show, bookings|
        bookings[show] = @booking_class.where(show_id: show.id)
      end
    end
  end
end
