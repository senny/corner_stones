module CornerStones
  class DefinitionList
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
      data_nodes.map {|term, definition|
        [term.text, definition.text]
      }.to_h
    end

    private
    def data_nodes
      terms = node.all("dt")
      definitions = node.all("dd")

      terms.zip(definitions)
    end
  end
end
