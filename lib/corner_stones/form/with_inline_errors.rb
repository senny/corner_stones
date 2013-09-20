module CornerStones
  class Form
    module WithInlineErrors
      class FormHasErrorsError < StandardError; end

      def submit(options = {})
        assert_valid = options.fetch(:assert_valid) { true }
        super
        assert_has_no_errors if assert_valid
      end

      def errors
        return [] unless first(@scope)

        within @scope do
          all(error_container_selector).map do |container|
            label = container.all('label').first
            input = container.all(CornerStones::Form::ENABLED_FIELDS_SELECTOR).first
            error = container.all(error_hint_selector).first

            { 'Field' => label && label.text.strip,
              'Value' => input && FieldSelector.find_by_element(input).get,
              'Error' => error && error.text }
          end
        end
      end

      def assert_has_no_errors
        unless errors == []
          error_message = 'expected the form to have no errors but the following were present:'
          errors.each do |error|
            error_message << "\n\t- #{error}"
          end
          error_message << "\n"
          raise FormHasErrorsError, error_message
        end
      end

      def error_container_selector
        ".error"
      end

      def error_hint_selector
        ".help-inline"
      end
    end
  end
end
