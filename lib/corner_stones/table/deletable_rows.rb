module CornerStones
  class Table
    module DeletableRows

      def delete_row(options)
        row = row(options)
        if row['Delete-Link']
          row['Delete-Link'].click
        else
          raise "The row matching '#{options}' does not have a delete-link"
        end
      end

      def attributes_for_row(row)
        super.merge('Delete-Link' => row.first('td .delete-action'))
      end

    end
  end
end
