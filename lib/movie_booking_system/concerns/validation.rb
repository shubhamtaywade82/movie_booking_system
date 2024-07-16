# frozen_string_literal: true

module MovieBookingSystem
  module Validation
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def validate_uniqueness_of(field)
        @unique_fields ||= []
        @unique_fields << field
      end

      def validate_presence_of(field)
        @required_fields ||= []
        @required_fields << field
      end

      def validate_type_of(field, type)
        @typed_fields ||= {}
        @typed_fields[field] = type
      end

      def unique_fields
        @unique_fields || []
      end

      def required_fields
        @required_fields || []
      end

      def typed_fields
        @typed_fields || {}
      end
    end

    def valid?
      validate
      @errors.empty?
    end

    def validate
      @errors = []
      validate_presence
      validate_uniqueness
      validate_type
    end

    def errors
      @errors ||= []
    end

    private

    def validate_presence
      self.class.required_fields.each do |field|
        next if field == :id

        value = send(field)
        @errors << "#{field} cannot be blank" if value.nil? || value.to_s.strip.empty?
      end
    end

    def validate_uniqueness
      self.class.unique_fields.each do |field|
        value = send(field)
        if self.class.all.any? { |record| record.send(field) == value && record != self }
          @errors << "#{field} must be unique"
        end
      end
    end

    def validate_type
      self.class.typed_fields.each do |field, type|
        value = send(field)
        case type
        when :integer
          @errors << "#{field} must be an integer" unless value.is_a?(Integer)
        when :date
          @errors << "#{field} must be a date" unless value.is_a?(Date)
        when :time
          @errors << "#{field} must be a time" unless value.is_a?(Time)
        end
      end
    end
  end
end
