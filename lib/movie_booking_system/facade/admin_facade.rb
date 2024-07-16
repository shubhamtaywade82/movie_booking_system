# frozen_string_literal: true

module MovieBookingSystem
  class AdminFacade
    def initialize
      @admin_service = AdminService.new
    end

    def add_movie(attributes)
      @admin_service.add_movie(attributes)
    end

    def update_movie(id, attributes)
      @admin_service.update_movie(id, attributes)
    end

    def add_show(attributes)
      @admin_service.add_show(attributes)
    end

    def update_show(id, attributes)
      @admin_service.update_show(id, attributes)
    end

    def list_movies
      @admin_service.list_movies
    end

    def list_shows
      @admin_service.list_shows
    end
  end
end
