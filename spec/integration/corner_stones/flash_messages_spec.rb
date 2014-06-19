require 'integration/spec_helper'

require 'corner_stones/flash_messages'

describe CornerStones::FlashMessages do

  stub_capybara_response

  let(:html_fixture) { <<-HTML
    <div class="alert">
      <p>Article was not saved. Please correct the errors.</p>
    </div>
    <div class="notice">
      <p>Article saved.</p>
    </div>
    <div class="notice">
      <p>Successfully logged in</p>
    </div>
  HTML
  }

  subject { CornerStones::FlashMessages.new}

  it 'assembles present messages into a hash' do
    subject.messages.must_equal(:alert => [{:text => 'Article was not saved. Please correct the errors.'}],
                                :notice => [{:text => 'Article saved.'}, {:text => 'Successfully logged in'}])
  end

  it 'you can select a message by type and content' do
    subject.message(:notice, 'Article saved.').must_equal({:text => 'Article saved.'})
  end

  it 'nil is returned when no message was found' do
    subject.message(:alert, 'Article saved.').must_equal(nil)
  end

  describe '#assert_flash_is_present' do
    it 'passes when the flash is present' do
      subject.assert_flash_is_present(:alert, 'Article was not saved. Please correct the errors.')
    end

    it 'fails when the flash is missing' do
      lambda do
        subject.assert_flash_is_present(:notice, 'I am not displayed')
      end.must_raise(CornerStones::FlashMessages::FlashMessageMissingError)
    end

    it 'the exception contains information about the present flash messages' do
      begin
        subject.assert_flash_is_present(:alert, 'this raises an error.')
      rescue => e
        e.message.must_equal <<-MESSAGE
the flash message: 'this raises an error.' with type: alert was not found.
The following messages were present:
- notice: Article saved.
- notice: Successfully logged in
- alert: Article was not saved. Please correct the errors.
MESSAGE
      end
    end
  end

  describe 'custom message types' do
    let(:html_fixture) { <<-HTML
      <div class="alert-error">
        <p>Article was not saved. Please correct the errors.</p>
      </div>
      <div class="alert-info">
        <p>Article saved.</p>
      </div>
      <div class="alert-info">
        <p>Successfully logged in</p>
      </div>
    HTML
    }

    subject { CornerStones::FlashMessages.new(:message_types => [:'alert-info', :'alert-error', :'alert-warning'])}

    it 'uses the :message_type option to determine the available messages' do
      subject.messages.must_equal(:'alert-error' => [{:text => 'Article was not saved. Please correct the errors.'}],
                                  :'alert-info' => [{:text => 'Article saved.'}, {:text => 'Successfully logged in'}])
    end

  end
end
