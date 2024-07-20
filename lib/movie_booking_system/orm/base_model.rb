# frozen_string_literal: true

require_relative "../helpers/base_model_helper"

module MovieBookingSystem
  class BaseModel
    include Validation
    include Association
    include BaseModelHelper
    attr_reader :attributes

    class << self
      attr_reader :fields, :fields_options

      def inherited(subclass)
        super
        subclass.field(:id)
      end

      def field(name, options = {})
        initialize_field(name, options)
        define_accessors(name, options[:type])
        validate_field(name, options)
      end

      def csv_filename(filename = nil)
        @csv_filename = filename if filename
        @csv_filename ||= "data/#{name.split("::").last.downcase.pluralize}.csv"
      end

      def file_path
        @csv_filename
      end

      def csv_handler
        @csv_handler ||= CSVHandler.new(csv_filename, fields)

        unless File.exist?(csv_filename)
          CSV.open(csv_filename, "w") do |csv|
            csv << fields
          end
        end

        @csv_handler
      end

      def all
        csv_handler.load_all.map { |row| new(row) }
      end

      def find(id)
        data = csv_handler.find_by_id(id)
        data ? new(data) : nil
      end

      def where(conditions)
        csv_handler.load_all.select { |row| conditions_match?(row, conditions) }.map { |row| new(row) }
      end

      def create(attributes = {})
        new(attributes).tap(&:save)
      end

      private

      def initialize_field(name, options)
        @fields ||= []
        @fields << name
        attr_accessor name

        @fields_options ||= {}
        @fields_options[name] = options
      end

      def define_accessors(name, type)
        define_type_conversion_method(name, type) if type

        define_method(name) do
          attributes[name]
        end

        define_method("#{name}=") do |value|
          @attributes[name] = convert_value(value, type)
        end
      end

      def validate_field(name, options)
        validate_uniqueness_of(name) if options[:unique]
        validate_presence_of(name) if options[:required]
        validate_type_of(name, options[:type]) if options[:type]
      end

      def define_type_conversion_method(name, type)
        define_method("#{name}=") do |value|
          @attributes[name] = convert_value(value, type)
        end
      end

      def convert_value(value, type)
        return value if value.is_a?(type_class(type))

        case type
        when :integer
          value.to_s.match?(/^\d+$/) ? value.to_i : value
        when :date
          Date.parse(value)
        when :time
          Time.parse(value)
        else
          value
        end
      end

      def type_class(type)
        case type
        when :integer
          Integer
        when :date
          Date
        when :time
          Time
        else
          Object
        end
      end

      def conditions_match?(row, conditions)
        conditions.all? { |key, value| row[key] == value }
      end
    end
  end
end
