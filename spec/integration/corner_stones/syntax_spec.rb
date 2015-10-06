require 'integration/spec_helper'

require 'corner_stones/table'
require 'corner_stones/syntax'

describe CornerStones::Syntax do
  include CornerStones::Syntax
  stub_capybara_response

  describe "#table" do
    let(:html_fixture) { <<-HTML
<table class="articles"></table>
    HTML
    }

    it "builds a CornerStones::Table" do
      my_table = table(".articles")
      my_table.must_be_kind_of(CornerStones::Table)
    end
  end

  describe "#form" do
    let(:html_fixture) { <<-HTML
<from action="/" class="user-form"></form>
    HTML
    }

    it "builds a CornerStones::Form" do
      my_form = form(".user-form")
      my_form.must_be_kind_of(CornerStones::Form)
    end
  end
end
