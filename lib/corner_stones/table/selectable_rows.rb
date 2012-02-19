module CornerStones
  class Table
    module SelectableRows

      def select_row(options)
        visit row(options)['Selected-Link']
      end

      def attributes_for_row(row)
        super.merge('Selected-Link' => row['data-selected-url'])
      end

    end
  end
end
