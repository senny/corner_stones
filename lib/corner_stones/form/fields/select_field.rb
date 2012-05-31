require 'corner_stones/form/fields/base'

module CornerStones
  class Form
    module Fields
      class SelectField < Base
        def self.handles?(name)
          !find_field(name).nil?
        end

        def self.find_field(name)
          first(:xpath, XPath::HTML.select(name))
        end

        def set(value)
          @field.find("option:contains('#{value}')").select_option
        end

        def get
          @field.value
        end
      end
    end
  end
end
