module CornerStones
  # This module provides syntactic sugar for your tests. To use it,
  # simply include the module into your class:
  #
  #   class ActionDispatch::IntegrationTest
  #     include CornerStones::Syntax
  #   end
  #
  # If you are using Cucumber you can mix the module into the <tt>World</tt>.
  #
  #   World(CornerStones::Syntax)
  module Syntax
    # Create a <tt>CornerStones::Table</tt> instance.
    def table(selector)
      CornerStones::Table.new(selector)
    end
  end
end
