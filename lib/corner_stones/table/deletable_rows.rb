module CornerStones
  class Table
    module DeletableRows

      def delete_row(options)
        warn "[DEPRECATION] `delete_row` is deprecated. Please use `row(row_spec).delete` instead."
        row(options).delete
      end

      def build_row(node)
        row = super
        row.extend RowMethods
        row
      end

      module RowMethods
        def delete
          delete_link = node.first('td .delete-action')
          if delete_link
            delete_link.click
          else
            raise "The row '#{attributes}' does not have a delete-link"
          end
        end
      end

    end
  end
end
