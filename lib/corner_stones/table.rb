require 'corner_stones/table/selectable_rows'
require 'corner_stones/table/deletable_rows'
require 'corner_stones/table/whitespace_filter'

class Hash
  def deep_merge(other_hash)
    dup.deep_merge!(other_hash)
  end
  def deep_merge!(other_hash)
    other_hash.each_pair do |k,v|
      tv = self[k]
      self[k] = tv.is_a?(Hash) && v.is_a?(Hash) ? tv.deep_merge(v) : v
    end
    self
  end
end

module CornerStones

  class Table

    class MissingRowError < StandardError; end

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
      } or raise MissingRowError, "no row with '#{options.inspect}'\n\ngot:#{rows}"
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
      row_data = {}
      headers.each.with_index.with_object(row_data) do |(header, index), row_data|
        augment_row_with_cell(row_data, row, index, header)
      end
      row_data['Row-Element'] = row
      row_data
    end

    def augment_row_with_cell(row_data, row, index, header)
      data = row.all(@data_selector)
      cell = data[index]
      row_data[header] = value_for_cell(cell)
    end

    def value_for_cell(cell)
      cell.text
    end
  end

end
