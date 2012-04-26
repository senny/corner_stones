module CornerStones
  class Form
    module Fields
      class Base
        def self.inherited(base)
          base.send :include, Capybara::DSL
          base.extend Capybara::DSL
        end

        def initialize(locator)
          @locator = locator
        end
      end
    end
  end
end
