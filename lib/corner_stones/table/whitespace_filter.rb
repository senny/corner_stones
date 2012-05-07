module CornerStones
  class Table
    module WhitespaceFilter
      def attributes_for_row(row)
        attributes = super
        attributes.each do |key, value|
          attributes[key] = value.strip if value.respond_to?(:strip)
        end
      end
    end
  end
end
