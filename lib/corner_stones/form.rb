require 'corner_stones/form/with_inline_errors'

module CornerStones
  class Form

    include Capybara::DSL

    def initialize(scope, options = {})
      @scope = scope
      @options = options
    end

    def process(params)
      fill_in_with(params[:fill_in])
      submit(params)
    end

    def submit(submit_options = {})
      submit_text = submit_options.fetch(:button) { 'Save' }
      within @scope do
        click_button(submit_text)
      end
    end

    def fill_in_with(attributes)
      within @scope do
        attributes.each do |name, value|
          if select_fields.include?(name)
            select(value, :from => name)
          elsif autocomplete_fields.include?(name)
            autocomplete(value, :in => name)
          elsif file_fields.include?(name)
            attach_file(name, value)
          else
            fill_in(name, :with => value)
          end
        end
      end
    end

    def autocomplete(value, options)
      autocomplete_id = find_field(options[:in])[:id]
      fill_in(options[:in], :with => value)
      page.execute_script %Q{ $('##{autocomplete_id}').trigger("focus") }
      page.execute_script %Q{ $('##{autocomplete_id}').trigger("keydown") }
      sleep 1
      page.execute_script %Q{ $('.ui-menu-item a:contains("#{value}")').trigger("mouseenter").trigger("click"); }
    end

    def select_fields
      @options.fetch(:select_fields) { [] }
    end

    def autocomplete_fields
      @options.fetch(:autocomplete_fields) { [] }
    end

    def file_fields
      @options.fetch(:file_fields) { [] }
    end
  end

end
