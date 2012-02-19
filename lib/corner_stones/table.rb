require 'corner_stones/table/selectable_rows'
require 'corner_stones/table/deletable_rows'

module CornerStones

  class Table
    include Capybara::DSL

    def initialize(scope, options = {})
      @scope = scope
      @data_selector = options.fetch(:data_selector) { 'td' }
      @options = options
    end

    def row(options)
      rows.detect { |row|
        identity = row.select { |key, value| options.has_key?(key) }
        identity == options
      }
    end

    def rows
      within @scope do
        all('tbody tr').map do |row|
          attributes_for_row(row)
        end
      end
    end

    def headers
      @options[:headers] || detect_table_headers
    end

    def detect_table_headers
      all('thead th').map(&:text)
    end

    def attributes_for_row(row)
      data = row.all(@data_selector)

      real_data = data[0...headers.size].map(&:text)

      Hash[headers.zip(real_data)]
    end
  end

end
