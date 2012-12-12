module CornerStones
  class Form
    module Disabled
      class NotAllFieldsDiabledError < StandardError; end

      def assert_is_disabled
        within @scope do
          all_fields = all(CornerStones::Form::ENABLED_FIELDS_SELECTOR)
          enabled_fields = all_fields.reject{|field| field[:disabled] == 'disabled'}

          if enabled_fields.any?
            error_message = 'expected the form to have no enabled fields but the following were present:'
            enabled_fields.each do |field|
              error_message << "\n- #{field[:name]}"
            end
            raise NotAllFieldsDiabledError, error_message
          end
        end
      end
    end
  end
end
