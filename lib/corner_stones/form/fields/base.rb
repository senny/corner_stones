module CornerStones
  class Form
    module Fields
      class Base
        def self.inherited(base)
          base.send :include, Capybara::DSL
          base.extend Capybara::DSL
        end

        def initialize(field)
          @field = field
        end
      end
    end
  end
end
