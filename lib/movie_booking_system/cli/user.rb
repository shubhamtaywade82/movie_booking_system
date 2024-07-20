# frozen_string_literal: true

require "tty-prompt"
require "tty-table"

module MovieBookingSystem
  # UserMenu class handles the user-related actions
  class UserMenu
    attr_reader :parent_menu

    # Initializes the UserMenu
    # @param prompt [TTY::Prompt] the TTY prompt instance
    # @param parent_menu [Object] the parent menu
    def initialize(prompt, parent_menu)
      @prompt = prompt
      @parent_menu = parent_menu
      @admin_service = AdminService.new
    end

    # Shows the user menu
    def show
      loop do
        display_choices
        action = @prompt.select("User Menu: Please choose an action:", choices, filter: true)
        action&.call
      rescue TTY::Reader::InputInterrupt
        break
      end
    end

    private

    def display_choices
      @choices = {
        "List Users": -> { list_users },
        "Add User": -> { add_user },
        "Update User": -> { update_user },
        "Delete User": -> { delete_user },
        Back: -> { parent_menu.show }
      }
    end

    def list_users
      users = @admin_service.list_users
      users.any? ? display_users_table(users) : puts("No users available.")
    end

    def add_user
      user_name = @prompt.ask("Enter the user's name:")
      user = @admin_service.create_user(name: user_name)
      puts "User created successfully." if user
    end

    def update_user
      user_id = select_user
      return unless user_id

      user_name = @prompt.ask("Enter the new user's name:")
      @admin_service.update_user(user_id, name: user_name)
      puts "User updated successfully."
    end

    def delete_user
      user_id = select_user
      return unless user_id

      @admin_service.delete_user(user_id)
      puts "User deleted successfully."
    end

    def select_user
      users = @admin_service.list_users
      return @prompt.select("Select a user from the list:", format_users_for_prompt(users), filter: true) if users.any?

      puts "No users available."
      nil
    end

    def format_users_for_prompt(users)
      users.map { |u| { name: "#{u.name} (#{u.id})", value: u.id } }
    end

    def display_users_table(users)
      table = TTY::Table.new(header: %w[ID Name], rows: users.map { |u| [u.id, u.name] })
      puts table.render(:unicode)
    end

    attr_reader :choices
  end
end
