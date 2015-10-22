require 'corner_stones/form/field_selector'

require 'corner_stones/form/disabled'
require 'corner_stones/form/with_inline_errors'

module CornerStones
  class Form

    class UnknownFieldError < RuntimeError; end
    class OptionNotFound < ArgumentError; end

    include Capybara::DSL

    ENABLED_FIELDS_SELECTOR = 'input:not([type="hidden"]), textarea, select, button'

    def initialize(scope, options = {})
      @scope = scope
      @options = options
    end

    def process(params)
      fill_in_with(params[:fill_in])
      submit(params)
    end

    def submit(submit_options = {})
      within @scope do
        if submit_options.has_key?(:button)
          click_on submit_options[:button]
        else
          find('input[type=submit]:first-of-type').click
        end
      end
    end

    def fill_in_with(attributes)
      within @scope do
        attributes.each do |name, value|
          field = FieldSelector.find(name, :autocomplete_fields => autocomplete_fields)
          field.set value
        end
      end
    end

    def attributes
      within @scope do
        all('label[for]').inject({}) do |result, label|
          begin
            field = FieldSelector.find(label[:for], :autocomplete_fields => autocomplete_fields)
            result[label.text] = field.get
          rescue UnknownFieldError
            result[label.text] = ""
          end
          result
        end
      end
    end

    def autocomplete_fields
      @options.fetch(:autocomplete_fields) { [] }
    end
  end

end
