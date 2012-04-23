require 'corner_stones/form/fields/base'

module CornerStones
  class Form
    module Fields
      class FileField < Base
        def self.handles?(name)
          !first(:xpath, XPath::HTML.file_field(name)).nil?
        end

        def set(value)
          attach_file @locator, value
        end
      end
    end
  end
end
