require 'corner_stones/form/field_selector'

require 'corner_stones/form/with_inline_errors'

module CornerStones
  class Form

    class UnknownFieldError < RuntimeError; end

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
      submit_text = submit_options.fetch(:button) { 'Save' }
      within @scope do
        click_button(submit_text)
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
          field = FieldSelector.find(label[:for], :autocomplete_fields => autocomplete_fields)
          result[label.text] = field.get
          result
        end
      end
    end

    def autocomplete_fields
      @options.fetch(:autocomplete_fields) { [] }
    end
  end

end
