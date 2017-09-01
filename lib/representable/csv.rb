begin
  require 'csv'
rescue LoadError => _
  abort "Missing dependency 'csv' for Representable::CSV"
end

module Representable
  # When included, registers the feature Representable::CSV
  module CSV
    def self.included(base)
      base.class_eval do
        include Representable
        extend ClassMethods
        register_feature Representable::CSV
      end
    end

    # Defining format_engine as it is used in the process
    module ClassMethods
      def format_engine
        Representable::CSV
      end
    end

    def to_csv(*_args)
      create_representation_with(::CSV::Row.new([], []), {}, Binding)
    end

    alias render :to_csv

    #
    class Binding < Representable::Binding
      def self.build_for(definition)
        return Collection.new(definition) if definition.array?
        new(definition)
      end

      def write(csv_row, fragment, as)
        csv_row << [as, fragment]
      end

      def serialize_method
        :to_csv
      end

      # NOTE: We don't want the csv file to have missing columns from the
      # ones set in the properties
      def skipable_empty_value?(_value)
        false
      end

      # Builder writing method
      class Collection < self
        include Representable::Binding::Collection

        def write(csv_table, rows, _as)
          rows.each { |row| csv_table << row }
          csv_table
        end
      end
    end
  end
end
