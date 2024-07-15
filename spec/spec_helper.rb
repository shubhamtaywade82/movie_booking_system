# frozen_string_literal: true

require "movie_booking_system"

Dir[File.join(__dir__, "support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Clean up data directories before and after the test suite runs
  config.before do
    clean_test_data
  end

  # config.after(:suite) do
  #   clean_test_data
  # end

  def clean_test_data
    data_directories = ["data", "spec/tmp"]
    data_directories.each do |dir|
      Dir.foreach(dir) do |file|
        file_path = File.join(dir, file)
        FileUtils.rm_f(file_path) if File.file?(file_path)
      end
    end
  end
end
