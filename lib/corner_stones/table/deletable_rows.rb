module CornerStones
  class Table
    module DeletableRows

      def delete_row(options)
        row(options)['Delete-Link'].click
      end

      def attributes_for_row(row)
        super.merge('Delete-Link' => row.first('td .delete-action'))
      end

    end
  end
end
