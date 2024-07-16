# frozen_string_literal: true

module MovieBookingSystem
  class CSVModel
    attr_reader :attributes

    class << self
      attr_reader :fields

      def field(name, options = {})
        @fields ||= []
        @fields << name
        attr_accessor name

        define_type_conversion_method(name, options[:type]) if options[:type]
      end

      def csv_filename(filename = nil)
        @csv_filename = filename if filename
        @csv_filename ||= "data/#{name.downcase.pluralize}.csv"
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
          @attributes[name] = case type
                              when :integer then value.to_i
                              when :date then Date.parse(value)
                              when :time then Time.parse(value)
                              else value
                              end
        end
      end
    end

    def initialize(attributes = {})
      @attributes = attributes
    end

    def save
      if attributes[:id]
        self.class.csv_handler.update_row(attributes[:id], attributes)
      else
        self.class.csv_handler.write_row(attributes)
      end
      reload_attributes
    end

    def reload_attributes
      @attributes = self.class.csv_handler.find_by_id(@attributes[:id])
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
      end.map { |row| new(row) } # rubocop:disable Style/MultilineBlockChain
    end

    def update(new_attributes)
      @attributes.merge!(new_attributes)
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
  end
end
