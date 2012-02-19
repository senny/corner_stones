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
        all('.error').map do |container|
          label = container.all('label').first
          input = container.all('input, textarea, select').first
          error = container.all('.help-inline').first

          { 'Field' => label && label.text,
            'Value' => input && input.value,
            'Error' => error && error.text }
        end
      end

      def assert_has_no_errors
        unless errors == []
          raise FormHasErrorsError
        end
      end

    end
  end
end
