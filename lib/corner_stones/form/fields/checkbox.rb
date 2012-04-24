require 'corner_stones/form/fields/base'

module CornerStones
  class Form
    module Fields
      class Checkbox < Base
        def self.handles?(name)
          !find_field(name).nil?
        end

        def self.find_field(name)
          first(:xpath, XPath::HTML.checkbox(name))
        end

        def set(value)
          if [true, 'yes', 'ja', '1', 1].include?(value)
            check @locator
          else
            uncheck @locator
          end
        end

        def get
          self.class.find_field(@locator).value
        end
      end
    end
  end
end
