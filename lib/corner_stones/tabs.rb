require 'corner_stones/tabs/active_tracking'

module CornerStones
  class Tabs

    include Capybara::DSL

    def initialize(element_scope)
      @element_scope = element_scope
    end

    def open(tab)
      within(@element_scope) do
        click_link(tab)
      end
    end

  end
end
