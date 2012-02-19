module CornerStones
  class Tabs
    module ActiveTracking

      class ActiveTabMismatchError < StandardError; end

      def open(tab)
        super
        assert_current_tab_is(tab)
      end

      def assert_current_tab_is(tab)
        current_tab = nil
        wait_until do
          current_tab = find(@element_scope).find('.active').text
          current_tab == tab
        end
      rescue Capybara::TimeoutError
        raise ActiveTabMismatchError, "the active tab is '#{current_tab}' instead of '#{tab}'"
      end

    end
  end
end
