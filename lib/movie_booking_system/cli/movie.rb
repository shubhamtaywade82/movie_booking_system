# frozen_string_literal: true

require "tty-prompt"
require "tty-table"

module MovieBookingSystem
  class MovieMenu
    attr_reader :parent_menu

    def initialize(prompt, parent_menu)
      @prompt = prompt
      @parent_menu = parent_menu
      @admin_service = AdminService.new
    end

    def show # rubocop:disable Metrics/MethodLength
      loop do
        choices = {
          "List Movies" => -> { list_movies },
          "Add Movie" => -> { add_movie },
          "Update Movie" => -> { update_movie },
          "Delete Movie" => -> { delete_movie },
          "Back" => -> { parent_menu.show }
        }

        action = @prompt.select("Movie Menu: Please choose an action:", choices, filter: true)
        action&.call
      rescue TTY::Reader::InputInterrupt
        break
      end
    end

    private

    def list_movies
      movies = @admin_service.list_movies
      if movies.any?
        display_movies_table(movies)
      else
        puts "No movies available."
      end
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
        return @prompt.select("Select a movie from the list:", format_movies_for_prompt(movies), filter: true)
      end

      puts "No movies available."
      nil
    end

    def format_movies_for_prompt(movies)
      movies.map { |m| { name: "#{m.title} (#{m.id})", value: m.id } }
    end

    def display_movies_table(movies)
      table = TTY::Table.new(header: %w[ID Title Genre Duration], rows: movies.map do |m|
                                                                          [m.id, m.title, m.genre, m.duration]
                                                                        end)
      puts table.render(:unicode)
    end
  end
end
