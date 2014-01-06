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
          link ||= delete_link
          if link
            link.click
          else
            raise "The row '#{attributes}' does not have a delete-link"
          end
        end

        def delete_link
          node.first('td .delete-action')
        end
      end
    end
  end
end
