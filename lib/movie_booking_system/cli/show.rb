# frozen_string_literal: true

require "tty-prompt"
require "tty-table"

module MovieBookingSystem
  class ShowMenu
    attr_reader :parent_menu

    def initialize(prompt, parent_menu)
      @prompt = prompt
      @parent_menu = parent_menu
      @admin_service = AdminService.new
    end

    def show # rubocop:disable Metrics/MethodLength
      loop do
        choices = {
          "List Shows" => -> { list_shows },
          "Add Show" => -> { add_show },
          "Update Show" => -> { update_show },
          "Delete Show" => -> { delete_show },
          "Back" => -> { parent_menu.show }
        }

        action = @prompt.select("Show Menu: Please choose an action:", choices, filter: true)
        action&.call
      rescue TTY::Reader::InputInterrupt
        break
      end
    end

    private

    def list_shows
      movie_id = select_movie
      return unless movie_id

      shows = @admin_service.list_shows_by_movie(movie_id)
      if shows.any?
        display_shows_table(shows)
      else
        puts "No shows available for this movie."
      end
    end

    def add_show
      movie_id = select_movie
      return unless movie_id

      show_attributes = collect_show_attributes
      @admin_service.add_show(movie_id, show_attributes)
      puts "Show added successfully."
    end

    def update_show
      movie_id = select_movie
      return unless movie_id

      show_id = select_show(movie_id)
      return unless show_id

      show_attributes = collect_show_attributes
      @admin_service.update_show(show_id, show_attributes)
      puts "Show updated successfully."
    end

    def delete_show
      movie_id = select_movie
      return unless movie_id

      show_id = select_show(movie_id)
      return unless show_id

      @admin_service.delete_show(show_id)
      puts "Show deleted successfully."
    end

    def collect_show_attributes
      show_time = @prompt.ask("Enter the show time (HH:MM format):")
      unless valid_time_format?(show_time)
        puts "Invalid time format. Please enter the time in HH:MM format."
        return
      end
      total_capacity = @prompt.ask("Enter the total capacity for the show:", convert: :int)
      { show_time: show_time, total_capacity: total_capacity }
    end

    def select_movie
      movies = @admin_service.list_movies
      return @prompt.select("Select a movie from the list:", format_movies_for_prompt(movies)) if movies.any?

      puts "No movies available."
      nil
    end

    def select_show(movie_id)
      shows = @admin_service.list_shows_by_movie(movie_id)
      return @prompt.select("Select a show from the list:", format_shows_for_prompt(shows)) if shows.any?

      puts "No shows available for this movie."
      nil
    end

    def format_movies_for_prompt(movies)
      movies.map { |m| { name: "#{m.title} (#{m.id})", value: m.id } }
    end

    def format_shows_for_prompt(shows)
      shows.map { |s| { name: "#{s.show_time} (#{s.id})", value: s.id } }
    end

    def display_shows_table(shows)
      table = TTY::Table.new(header: ["ID", "Movie ID", "Show Time", "Capacity", "Available Seats"],
                             rows: shows.map do |s|
                                     [s.id, s.movie_id, s.show_time, s.total_capacity, s.available_seats]
                                   end)
      puts table.render(:unicode)
    end

    def valid_time_format?(time_string)
      !!(time_string =~ /^([01]\d|2[0-3]):([0-5]\d)$/)
    end
  end
end
