# frozen_string_literal: true

require "tty-prompt"
require "tty-table"

module MovieBookingSystem
  # MovieMenu class handles the movie-related actions
  class MovieMenu
    attr_reader :parent_menu

    # Initializes the MovieMenu
    # @param prompt [TTY::Prompt] the TTY prompt instance
    # @param parent_menu [Object] the parent menu
    def initialize(prompt, parent_menu)
      @prompt = prompt
      @parent_menu = parent_menu
      @admin_service = AdminService.new
    end

    # Shows the movie menu
    def show
      loop do
        display_choices
        action = @prompt.select("Movie Menu: Please choose an action:", choices, filter: true)
        action&.call
      rescue TTY::Reader::InputInterrupt
        break
      end
    end

    private

    def display_choices
      @choices = {
        "List Movies": -> { list_movies },
        "Add Movie": -> { add_movie },
        "Update Movie": -> { update_movie },
        "Delete Movie": -> { delete_movie },
        Back: -> { parent_menu.show }
      }
    end

    def list_movies
      movies = @admin_service.list_movies
      movies.any? ? display_movies_table(movies) : puts("No movies available.")
    end

    def add_movie
      movie_attributes = collect_movie_attributes
      @admin_service.add_movie(movie_attributes)
      puts "Movie added successfully."
    end

    def update_movie
      movie_id = select_movie
      return unless movie_id

      movie_attributes = collect_movie_attributes
      @admin_service.update_movie(movie_id, movie_attributes)
      puts "Movie updated successfully."
    end

    def delete_movie
      movie_id = select_movie
      return unless movie_id

      @admin_service.delete_movie(movie_id)
      puts "Movie deleted successfully."
    end

    def collect_movie_attributes
      title = @prompt.ask("Enter the movie title:")
      genre = @prompt.ask("Enter the movie genre:")
      duration = @prompt.ask("Enter the movie duration (in minutes):", convert: :int)
      { title: title, genre: genre, duration: duration }
    end

    def select_movie
      movies = @admin_service.list_movies
      if movies.any?
        return @prompt.select(
          "Select a movie from the list:", format_movies_for_prompt(movies),
          filter: true
        )
      end

      puts "No movies available."
      nil
    end

    def format_movies_for_prompt(movies)
      movies.map { |m| { name: "#{m.title} (#{m.id})", value: m.id } }
    end

    def display_movies_table(movies)
      table = TTY::Table.new(
        header: %w[ID Title Genre Duration],
        rows: movies.map { |m| [m.id, m.title, m.genre, m.duration] }
      )
      puts table.render(:unicode)
    end

    attr_reader :choices
  end
end
