require 'integration/spec_helper'

require 'corner_stones/table'
require 'corner_stones/syntax'

describe CornerStones::Syntax do
  include CornerStones::Syntax
  stub_capybara_response

  describe "#table" do
    let(:html) { <<-HTML
<table class="articles"></table>
    HTML
    }

    it "builds a CornerStones::Table" do
      my_table = table(".articles")
      my_table.must_be_kind_of(CornerStones::Table)
    end
  end
end
