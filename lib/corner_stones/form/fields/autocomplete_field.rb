require 'corner_stones/form/fields/base'

module CornerStones
  class Form
    module Fields
      class AutocompleteField < TextField
        def self.handles?(name)
          all(:xpath, XPath::HTML.fillable_field(name)).any? do |field|
            field[:class] =~ /ui-autocomplete-input/
          end
        end

        def set(value)
          autocomplete_id = @field[:id]
          super
          page.execute_script %Q{ $('##{autocomplete_id}').trigger("focus") }
          page.execute_script %Q{ $('##{autocomplete_id}').trigger("keydown") }
          wait_until do
            result = page.evaluate_script %Q{ $('.ui-menu-item a:contains("#{value}")').size() }
            result > 0
          end
          page.execute_script %Q{ $('.ui-menu-item a:contains("#{value}")').trigger("mouseenter").trigger("click"); }
        end
      end
    end
  end
end
