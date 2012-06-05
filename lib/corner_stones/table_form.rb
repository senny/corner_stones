require 'corner_stones/table'

module CornerStones
  class TableForm < Table

    class InvalidOptionsError < StandardError; end
    class MissingInputError < StandardError; end

    def fill_in_row(row_spec, options = {})
      raise InvalidOptionsError, "No option :with specified" unless options.include?(:with)
      row = row(row_spec)
      options[:with].each do |field_name, value|
        field = row['Inputs'][field_name]
        raise MissingInputError, "the column #{field_name} does not have any input fields" unless field
        field.set value
      end
    end

    def fill_in_table(array_of_attributes)
      array_of_attributes.each do |attributes|
        row_spec = calculate_row_spec(attributes)
        fill_in_row row_spec, :with => attributes.reject{|key, value| row_spec.include?(key)}
      end
    end

    def calculate_row_spec(attributes)
      data_keys = headers - input_columns
      attributes.select {|key, value| data_keys.include?(key)}
    end
    private :calculate_row_spec

    def input_columns
      rows.map {|row| row['Inputs'].keys }.flatten.uniq
    end

    def submit(submit_options = {})
      Form.new(@scope).submit(submit_options)
    end

    def attributes
      within @scope do
        all('tbody tr').each_with_object([]) do |row, result|
          result << attributes_for_row(row).select{|key, value| headers.include? key}
        end
      end
    end

    def augment_row_with_cell(row_data, row, index, header)
      row_data['Inputs'] ||= {}
      data = row.all(@data_selector)
      cell = data[index]
      element = input_field(cell)
      cell = data[index]
      if element
        field = Form::FieldSelector.find_by_element(element)
        row_data['Inputs'][header] = field
        row_data[header] = field.get
      else
        row_data[header] = value_for_cell(cell)
      end
    end

    def input_field(cell)
      cell.first('input:not([type=\'hidden\']), textarea:not([type=\'hidden\']), select:not([type=\'hidden\'])')
    end
    private :input_field
  end
end
