# frozen_string_literal: true

module MovieBookingSystem
  module Association
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def belongs_to(association_name, options = {})
        foreign_key = options[:foreign_key] || :"#{association_name}_id"
        field foreign_key, type: :integer unless fields.include?(foreign_key)

        define_method(association_name) do
          association_class = options[:class_name] || self.class.classify(association_name.to_s.singularize)
          association_class.find(@attributes[foreign_key])
        end
      end

      def has_many(association_name, options = {})
        define_method(association_name) do
          association_class = options[:class_name] || self.class.classify(association_name.to_s.singularize)
          foreign_key = options[:foreign_key] || :"#{self.class.name.split("::").last.underscore}_id"
          association_class.where(foreign_key => @attributes[:id])
        end
      end

      # Helper method for string classification (similar to ActiveSupport's classify)
      def classify(string)
        MovieBookingSystem.const_get(string.split("_").collect(&:capitalize).join)
      end
    end
  end
end
