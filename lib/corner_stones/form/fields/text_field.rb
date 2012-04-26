require 'corner_stones/form/fields/base'

module CornerStones
  class Form
    module Fields
      class TextField < Base
        def self.handles?(name)
          !find_field(name).nil?
        end

        def self.find_field(name)
          first(:xpath, XPath::HTML.fillable_field(name))
        end

        def set(value)
          fill_in @locator, :with => value
        end

        def get
          self.class.find_field(@locator).value
        end
      end
    end
  end
end
