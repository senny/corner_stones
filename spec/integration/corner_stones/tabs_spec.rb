require 'integration/spec_helper'

require 'corner_stones/tabs'
require 'corner_stones/tabs/active_tracking'

describe CornerStones::Tabs do

  stub_capybara_response
  let(:html_fixture) {<<-HTML
      <ul class="main-tabs-nav">
        <li class="active"><a href='/main'>Main</a></li>
        <li><a href='/details'>Details</a></li>
        <li><a href='/more_stuff'>More Stuff</a></li>
      </ul>
  HTML
  }

  subject { CornerStones::Tabs.new('.main-tabs-nav') }

  it 'opens a given tab' do
    subject.open('Details')
    current_path.must_equal '/details'
  end

  describe 'mixins' do
    describe 'active tab tracking' do
      before do
        subject.extend(CornerStones::Tabs::ActiveTracking)
      end

      it 'asserts the current tab after opening a new tab' do
        lambda do
          subject.open('More Stuff')
        end.must_raise CornerStones::Tabs::ActiveTracking::ActiveTabMismatchError
      end

      describe '#assert_current_tab_is' do
        it 'passes when the given tab is active' do
          subject.assert_current_tab_is('Main')
        end

        it 'fails when the given tab is not active' do
          lambda do
            subject.assert_current_tab_is('More Stuff')
          end.must_raise CornerStones::Tabs::ActiveTracking::ActiveTabMismatchError
        end
      end
    end
  end

end
