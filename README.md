# MovieBookingSystem

A comprehensive movie booking system implemented in Ruby, using CSV for data storage. This gem provides functionalities for managing movies, shows, and bookings through an interactive CLI.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add movie_booking_system

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install movie_booking_system

## Usage

To start using the movie booking system, you can initiate the CLI by running:

```sh
$ bin/console
```

This will open an interactive console where you can choose actions from the menu.

### Admin Menu

The Admin Menu provides options for managing movies and shows:

- **List Movies**: List all movies in the system.
- **Add Movie**: Add a new movie to the system.
- **Update Movie**: Update an existing movie's details.
- **Delete Movie**: Delete a movie from the system.
- **List Shows (Select Movie)**: List all shows for a selected movie.
- **Add Show (Select Movie)**: Add a new show for a selected movie.
- **Show Bookings for Movie Show**: Show bookings for each movie show.

### Booking Menu

The Booking Menu provides options for managing bookings:

- **Make Booking**: Make a new booking for a selected show.
- **Cancel Booking**: Cancel an existing booking.

## Example Workflow

1. **Add a Movie**

    ```sh
    $ bin/console
    Choose an action: Admin Menu
    Admin Menu: Add Movie
    Title: Inception
    Genre: Sci-Fi
    Duration (mins): 148
    Movie added successfully.
    ```

2. **List Movies**

    ```sh
    Admin Menu: List Movies
    1: Inception (Sci-Fi) - Duration: 148 mins
    ```

3. **Add a Show for the Movie**

    ```sh
    Admin Menu: Add Show (Select Movie)
    Select a movie: Inception (1)
    Show Time (HH:MM): 20:00
    Total Capacity: 100
    Show added successfully.
    ```

4. **Make a Booking**

    ```sh
    Booking Menu: Make Booking
    User ID: 1
    Select a movie: Inception (1)
    Select a show: 20:00 (1)
    Number of seats: 2
    Booking created successfully. Seats: A1, A2
    ```

5. **Cancel a Booking**

    ```sh
    Booking Menu: Cancel Booking
    Select a booking to cancel: Booking #1: Show ID 1, Seats 2
    Booking cancelled successfully.
    ```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/shubhamtaywade82/movie_booking_system. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/shubhamtaywade82/movie_booking_system/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the MovieBookingSystem project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/shubhamtaywade82/movie_booking_system/blob/master/CODE_OF_CONDUCT.md).
```

This `README.md` file provides a comprehensive overview of the gem's functionality, installation instructions, usage examples, and information on contributing to the project. It covers the main features, including the Admin and Booking menus, and provides a step-by-step example workflow for common tasks.