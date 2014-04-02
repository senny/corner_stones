module CornerStones
  class Form
    module Fields
      class SelectField < Base
        def self.handles?(name)
          !find_field(name).nil?
        end

        def self.handles_element?(element)
          element.tag_name == 'select'
        end

        def self.find_field(name)
          first(:xpath, XPath::HTML.select(name))
        end

        def set(values)
          Array(values).each do |value|
            options = @field.all("option")
            selected_option = options.detect {|o| o.text == value}
            selected_option ||= options.detect {|o| o.text.include? value}
            selected_option.select_option
          end
        end

        def get
          case @field.value
          when Array
            @field.value.map do |value|
              @field.find("option[value='#{value}']").text
            end
          else
            @field.find("option[value='#{@field.value}']").text
          end
        end
      end
    end
  end
end
