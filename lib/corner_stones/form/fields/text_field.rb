require 'corner_stones/form/fields/base'

module CornerStones
  class Form
    module Fields
      class TextField < Base
        def self.handles?(name)
          !first(:xpath, XPath::HTML.fillable_field(name)).nil?
        end

        def set(value)
          fill_in @locator, :with => value
        end
      end
    end
  end
end
