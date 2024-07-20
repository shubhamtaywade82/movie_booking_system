# frozen_string_literal: true

module MovieBookingSystem
  module BaseModelHelper
    def initialize(attributes = {})
      @attributes = {}
      @errors = []
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
      csv_handler.load_all.select { |row| conditions_match?(row, conditions) }.map { |row| new(row) }
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

    def conditions_match?(row, conditions)
      conditions.all? { |key, value| row[key] == value }
    end
  end
end
