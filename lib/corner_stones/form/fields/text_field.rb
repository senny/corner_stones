module CornerStones
  class Form
    module Fields
      class TextField < Base
        def self.handles?(name)
          !find_field(name).nil?
        end

        def self.handles_element?(element)
          ['input', 'textarea'].include?(element.tag_name) && !['submit', 'image', 'radio', 'checkbox', 'hidden', 'file'].include?(element[:type])
        end

        def self.find_field(name)
          first(:xpath, XPath::HTML.fillable_field(name))
        end

        def set(value)
          @field.set value
        end

        def get
          @field.value
        end
      end
    end
  end
end
