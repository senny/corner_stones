module CornerStones
  class Table
    module SelectableRows

      def select_row(options)
        warn "[DEPRECATION] `select_row` is deprecated. Please use `row(row_spec).select` instead."
        row(options).select
      end

      def build_row(node)
        row = super
        row.extend RowMethods
        row
      end

      module RowMethods
        def select
          visit node['data-selected-url']
        end
      end

    end
  end
end
