require 'corner_stones/form/fields/base'

module CornerStones
  class Form
    module Fields
      class Checkbox < Base
        def self.handles?(name)
          !find_field(name).nil?
        end

        def self.handles_element?(element)
          element.tag_name == 'input' && element[:type] == 'checkbox'
        end

        def self.find_field(name)
          first(:xpath, XPath::HTML.checkbox(name))
        end

        def set(value)
          @field.set [true, 'yes', 'ja', '1', 1].include?(value)
        end

        def get
          @field[:checked] ? @field[:value] : nil
        end
      end
    end
  end
end
