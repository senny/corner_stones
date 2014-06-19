require 'integration/spec_helper'

require 'corner_stones/definition_list'

describe CornerStones::DefinitionList do

  stub_capybara_response

  let(:html) { <<-HTML
    <dl class="dl-horizontal">
      <dt>Description lists</dt>
      <dd>A description list is perfect for defining terms.</dd>
      <dt>Euismod</dt>
      <dd>Donec id elit non mi porta gravida at eget metus.</dd>
      <dt>Malesuada porta</dt>
      <dd>Etiam porta sem malesuada magna mollis euismod.</dd>
    </dl>
  HTML
  }

  subject { CornerStones::DefinitionList.new '.dl-horizontal' }

  it "extracts information as a hash dt => dd" do
    subject.data.must_equal({
                              "Description lists" => "A description list is perfect for defining terms.",
                              "Euismod" => "Donec id elit non mi porta gravida at eget metus.",
                              "Malesuada porta" => "Etiam porta sem malesuada magna mollis euismod."
                            })
  end

  it "allows hash access to individual entries" do
    subject["Euismod"].must_equal("Donec id elit non mi porta gravida at eget metus.")
    subject["Malesuada porta"].must_equal("Etiam porta sem malesuada magna mollis euismod.")
  end
end
