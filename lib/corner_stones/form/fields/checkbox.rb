require 'corner_stones/form/fields/base'

module CornerStones
  class Form
    module Fields
      class Checkbox < Base
        def self.handles?(name)
          !first(:xpath, XPath::HTML.checkbox(name)).nil?
        end

        def set(value)
          if [true, 'yes', 'ja', '1', 1].include?(value)
            check @locator
          else
            uncheck @locator
          end
        end
      end
    end
  end
end
