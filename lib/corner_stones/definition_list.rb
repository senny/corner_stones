module CornerStones
  class DefinitionList
    include Capybara::DSL

    def initialize(selector)
      @selector = selector
    end

    def node
      find(@selector)
    end

    def [](term)
      data[term]
    end

    def data
      Hash[data_nodes.map {|term, definition|
        [term.text, definition.text]
      }]
    end

    private
    def data_nodes
      terms = node.all("dt")
      definitions = node.all("dd")

      terms.zip(definitions)
    end
  end
end
