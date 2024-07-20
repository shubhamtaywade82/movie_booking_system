# frozen_string_literal: true

require "csv"
require "time"

module MovieBookingSystem
  class CSVHandler
    attr_reader :file_path

    def initialize(file_path, headers)
      @file_path = file_path
      @headers = headers
      ensure_file_exists
    end

    def ensure_file_exists
      FileUtils.mkdir_p(File.dirname(file_path))
      return if File.exist?(file_path)

      CSV.open(file_path, "w") do |csv|
        csv << @headers
      end
    end

    def load_all
      return [] unless File.exist?(file_path)

      CSV.read(file_path, headers: true, header_converters: :symbol).map(&:to_h).map do |row|
        row.transform_values { |value| parse_value(value) }
      end
    end

    def find_by_id(id)
      load_all.find { |row| row[:id] == id }
    end

    def write_row(row)
      row[:id] ||= next_id
      CSV.open(file_path, "a") do |csv|
        csv << row.values_at(*@headers)
      end
    end

    def update_row(id, new_attributes)
      rows = load_all
      index = rows.index { |row| row[:id] == id }
      return unless index

      rows[index] = rows[index].merge(new_attributes)
      save_data(rows)
    end

    def delete_row(id)
      rows = load_all
      rows.reject! { |row| row[:id] == id }
      save_data(rows)
    end

    def save_data(data)
      CSV.open(file_path, "w", headers: @headers, write_headers: true) do |csv|
        data.each { |row| csv << row.values_at(*@headers) }
      end
    end

    private

    def next_id
      (load_all.map { |row| row[:id] }.max || 0) + 1
    end

    def parse_value(value)
      case value
      when /^\d+$/
        value.to_i
      when /^\d{4}-\d{2}-\d{2}$/
        Date.parse(value)
      when /^\d{2}:\d{2}$/
        Time.parse(value)
      else
        value
      end
    end
  end
end
