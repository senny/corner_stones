require 'corner_stones/form/fields/text_field'
require 'corner_stones/form/fields/select_field'
require 'corner_stones/form/fields/file_field'
require 'corner_stones/form/fields/checkbox'
require 'corner_stones/form/fields/autocomplete_field'

module CornerStones
  class Form
    module FieldSelector
      FIELDS = [Fields::AutocompleteField, Fields::TextField, Fields::SelectField, Fields::FileField, Fields::Checkbox]

      def self.find(name, options = {})
        field_class = if options[:autocomplete_fields].include?(name)
                        Fields::AutocompleteField
                      else
                        FIELDS.detect {|selector| selector.handles?(name)}
                      end
        raise UnknownFieldError, "don't know how to fill the field #{name}" if field_class.nil?
        field_class.new(field_class.find_field(name))
      end
    end
  end
end
