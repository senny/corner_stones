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
        current_tab = find(@element_scope).find('.active').text
        current_tab == tab || raise
      rescue
        raise ActiveTabMismatchError, "the active tab is '#{current_tab}' instead of '#{tab}'"
      end

    end
  end
end
