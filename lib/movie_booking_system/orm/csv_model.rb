# frozen_string_literal: true

module MovieBookingSystem
  class CSVModel
    include Validation
    include Association
    attr_reader :attributes

    class << self
      attr_reader :fields, :fields_options

      def field(name, options = {})
        @fields ||= []
        @fields << name
        attr_accessor name

        @fields_options ||= {}
        @fields_options[name] = options

        define_type_conversion_method(name, options[:type]) if options[:type]
        validate_uniqueness_of(name) if options[:unique]
        validate_presence_of(name) if options[:required]
        validate_type_of(name, options[:type]) if options[:type]

        # Define getter method
        define_method(name) do
          attributes[name]
        end

        # Define setter method
        define_method("#{name}=") do |value|
          @attributes[name] = convert_value(value, options[:type])
        end
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

        # Create the CSV file if it doesn't exist
        unless File.exist?(csv_filename)
          CSV.open(csv_filename, "w") do |csv|
            csv << fields
          end
        end

        @csv_handler
      end

      private

      def define_type_conversion_method(name, type)
        define_method("#{name}=") do |value|
          @attributes[name] = convert_value(value, type)
        end
      end

      def convert_value(value, type)
        case type
        when :integer
          value.to_s.match?(/^\d+$/) ? value.to_i : value
        when :date then begin
          Date.parse(value)
        rescue StandardError
          value
        end
        when :time then begin
          Time.parse(value)
        rescue StandardError
          value
        end
        else value
        end
      end
    end

    def initialize(attributes = {})
      @attributes = {}
      @errors = []
      # Initialize attributes from hash while converting types
      attributes.each do |field, value|
        send("#{field}=", value) if self.class.fields.include?(field)
      end
    end

    def save
      validate
      return false unless valid?

      if attributes[:id]
        self.class.csv_handler.update_row(attributes[:id], attributes)
      else
        self.class.csv_handler.write_row(attributes)
      end
      reload_attributes
      self
    end

    def reload_attributes
      @attributes = self.class.csv_handler.find_by_id(@attributes[:id])
      apply_type_conversion
    end

    def self.create(attributes = {})
      new(attributes).tap(&:save)
    end

    def self.find(id)
      data = csv_handler.find_by_id(id)
      data ? new(data) : nil
    end

    def self.all
      csv_handler.load_all.map { |row| new(row) }
    end

    def self.where(conditions)
      csv_handler.load_all.select do |row|
        conditions.all? { |key, value| row[key] == value }
      end.map { |row| new(row) }
    end

    def update(new_attributes)
      @attributes.merge!(new_attributes)
      apply_type_conversion
      save
    end

    def destroy
      self.class.csv_handler.delete_row(attributes[:id])
    end

    def [](key)
      attributes[key]
    end

    def []=(key, value)
      attributes[key] = value
    end

    def to_h
      attributes.dup
    end

    def ==(other)
      other.is_a?(self.class) && attributes == other.attributes
    end

    private

    def convert_value(value, type)
      self.class.send(:convert_value, value, type)
    end

    def apply_type_conversion
      self.class.fields_options.each do |field, options|
        next unless options[:type]

        send("#{field}=", attributes[field])
      end
    end
  end
end
