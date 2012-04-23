require 'corner_stones/form/fields/base'

module CornerStones
  class Form
    module Fields
      class SelectField < Base
        def self.handles?(name)
          !first(:xpath, XPath::HTML.select(name)).nil?
        end

        def set(value)
          select value, :from => @locator
        end
      end
    end
  end
end
