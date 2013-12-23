require 'integration/spec_helper'

require 'corner_stones/form'
require 'corner_stones/form/with_inline_errors'
require 'corner_stones/form/disabled'

describe CornerStones::Form do

  stub_capybara_response

  let(:html) {<<-HTML
    <form action="/articles" method="post" class="article-form">
      <label for="title">Title</label>
      <input type="text" name="title" id="title">

      <label for="password">Password</label>
      <input type="password" name="password" id="password">

      <label for="author">Author</label>
      <select name="author" id="author">
        <option value="1">Robert C. Martin</option>
        <option value="2">Eric Evans</option>
        <option value="3">Kent Beck</option>
      </select>

      <label for="body">Body</label>
      <textarea name="body" id="body">
      </textarea>

      <label for="file">File</label>
      <input name="file" id="file" type="file">

      <label for="check">Checkbox</label>
      <input name="check" id="check" type="checkbox" value="1">

      <label for="check2">Checkbox2</label>
      <input name="check2" id="check2" type="checkbox" value="1">

      <input type="submit" name="button" value="Save">
      <input type="submit" name="button" value="Save Article">

    </form>
  HTML
  }

  subject { CornerStones::Form.new('.article-form') }

  it 'allows you to fill in the form' do
    subject.fill_in_with('Title' => 'Domain Driven Design',
                         'Password' => 'secret',
                         'Author' => 'Eric Evans',
                         'Body' => '...',
                         'File' => 'spec/files/hadoken.png',
                         'Checkbox' => true)

    find('#title').value.must_equal 'Domain Driven Design'
    find('#password').value.must_equal 'secret'
    find('#author').value.must_equal '2'
    find('#body').value.must_equal '...'
    find('#file').value.must_equal 'spec/files/hadoken.png'
    find('#check')[:checked].must_equal true
  end

  it 'allows you to submit the form' do
    subject.submit

    current_path.must_equal '/articles'
    page.driver.request.post?.must_equal true
  end

  it 'you can supply the submit-button text with the :button option' do
    subject.submit(:button => 'Save Article')

    page.driver.request.params['button'].must_equal 'Save Article'
  end

  it 'allows you to process (fill_in_with + submit) the form' do
    subject.process(:fill_in => {
                      'Title' => 'Domain Driven Design',
                      'Password' => 'SeCrEt',
                      'Author' => 'Eric Evans',
                      'Body' => 'Some Content...',
                      'File' => 'spec/files/hadoken.png',
                      'Checkbox' => true})

    current_path.must_equal '/articles'
    page.driver.request.post?.must_equal true

    page.driver.request.params.must_equal({"title" => "Domain Driven Design", 'password' => 'SeCrEt', "author" => "2", "body" => "Some Content...", "file" => "hadoken.png", 'check' => '1', 'button' => 'Save'})
  end

  it 'allows you to process (fill_in_with + submit) the form using an alternate button' do
    subject.process(:fill_in => {'Title' => 'Domain Driven Design',
                      'Author' => 'Eric Evans',
                      'Body' => 'Some Content...'},
                    :button => 'Save Article')

    page.driver.request.params['button'].must_equal('Save Article')
  end

  it 'allows you the retrieve the current values of the form fields' do
    subject.fill_in_with('Title' => 'Domain Driven Design',
                         'Password' => 'secret',
                         'Author' => 'Eric Evans',
                         'Body' => '...',
                         'File' => 'spec/files/hadoken.png',
                         'Checkbox' => true,
                         'Checkbox2' => false)

    subject.attributes.must_equal('Title' => 'Domain Driven Design',
                                  'Password' => 'secret',
                                  'Author' => 'Eric Evans',
                                  'Body' => '...',
                                  'File' => 'spec/files/hadoken.png',
                                  'Checkbox' => '1',
                                  'Checkbox2' => nil)
  end

  describe 'form with an unknown field type' do
    let(:html) {<<-HTML
      <form action="/articles" method="post" class="form-with-errors article-form">
        <label for="unknown">Unknown</label>
        <a id="unknown">Link</a>
      </form>
HTML
    }

    it 'raises an error when filling the form' do
      assert_raises(CornerStones::Form::UnknownFieldError) { subject.fill_in_with('Unknown' => '123456') }
    end
  end

  describe 'with select-fields with options containing the same text' do
    let(:html) {<<-HTML
      <form action="/articles" method="post" class="form-with-errors article-form">
        <label for="page_size">Page size</label>
        <select name="page_size" id="page_size">
          <option value="1">1/2 A4</option>
          <option value="2">A4</option>
          <option value="3">A3</option>
        </select>
        <input type="submit" name="button" value="Save">
      </form>
HTML
    }

    it 'sets the option containing the most matching text' do
      subject.process(:fill_in => {'Page size' => 'A4'},
                      :button => 'Save')

      page.driver.request.params['page_size'].must_equal('2')
    end

    it "works with options which don't match exactly" do
      subject.process(:fill_in => {'Page size' => '1/2'},
                      :button => 'Save')

      page.driver.request.params['page_size'].must_equal('1')
    end
  end

  describe 'mixins' do
    describe 'disabled' do
      before do
        subject.extend(CornerStones::Form::Disabled)
      end

      describe 'without all fields disabled' do
        let(:html) {<<-HTML
          <form action="/articles" method="post" class="form-without-errors article-form">
            <label for="title">Title</label>
            <input type="text" name="title" id="title">
            <label for="title">AGB</label>
            <input type="checkbox" name="agb" id="agb" disabled="disabled">
            <label for="author">Author</label>
            <select name="author" id="author">
              <option value="1">Robert C. Martin</option>
              <option value="2">Eric Evans</option>
              <option value="3">Kent Beck</option>
            </select>
            <label for="text">Text</label>
            <textarea name="text" id="text" disabled="disabled"></texarea>

            <input type="submit" value="Save" disabled="disabled">
            <button value="Cancel" disabled="disabled">
          <form>
        HTML
        }

        it 'the form is not disabled' do
          e = lambda do
            subject.assert_is_disabled
          end.must_raise(CornerStones::Form::Disabled::NotAllFieldsDiabledError)
          e.message.must_equal 'expected the form to have no enabled fields but the following were present:
- title
- author'
        end
      end

      describe 'with all fields disabled' do
        let(:html) {<<-HTML
          <form action="/articles" method="post" class="form-without-errors article-form">
            <label for="title">Title</label>
            <input type="text" name="title" id="title" disabled="disabled">
            <label for="title">AGB</label>
            <input type="checkbox" name="agb" id="agb" disabled="disabled">
            <label for="author">Author</label>
            <select name="author" id="author" disabled="disabled">
              <option value="1">Robert C. Martin</option>
              <option value="2">Eric Evans</option>
              <option value="3">Kent Beck</option>
            </select>
            <label for="text">Text</label>
            <textarea name="text" id="text" disabled="disabled"></texarea>

            <input type="submit" value="Save" disabled="disabled">
            <button value="Cancel" disabled="disabled">
          <form>
        HTML
        }

        it 'the form is disabled' do
          subject.assert_is_disabled
        end
      end
    end

    describe 'form errors' do

      before do
        subject.extend(CornerStones::Form::WithInlineErrors)
      end

      describe 'with errors' do
        let(:html) {<<-HTML
          <form action="/articles" method="post" class="form-with-errors article-form">
            <div>
              <label for="title">Title</label>
              <input type="text" name="title" id="title">
            </div>

            <div class="error">
              <label for="author">Author</label>
              <select name="author" id="author">
                <option value="1">Robert C. Martin</option>
                <option value="2">Eric Evans</option>
                <option value="3">Kent Beck</option>
              </select>
              <span class="help-inline">The author is not active</span>
            </div>

            <div class="error">
              <label for="body">Body</label>
              <textarea name="body" id="body">...</textarea>
              <span class="help-inline">invalid body</span>
            </div>

            <div class="error">
              <input name="nominated" type="hidden" value="0">
              <label for="nominated">
                <input name="nominated" id="nominated" type="checkbox" checked="checked" value="3">
                Nominated
              </label>
              <span class="help-inline">invalid nomination</span>
            </div>

          <input type="submit" value="Save">

          </form>
        HTML
        }

        it 'assembles the errors into a hash' do
          subject.errors.must_equal([{"Field" => "Author", "Value" => "Robert C. Martin", "Error" => "The author is not active"},
                                     {"Field" => "Body", "Value" => "...", "Error" => "invalid body"},
                                     {'Field' => 'Nominated', 'Value' => '3', 'Error' => 'invalid nomination'}])
        end

        it '#assert_has_no_errors fails' do
          lambda do
            subject.assert_has_no_errors
          end.must_raise(CornerStones::Form::WithInlineErrors::FormHasErrorsError)
        end

        it 'does not allow you to submit the form by default' do
          lambda do
            subject.submit
          end.must_raise(CornerStones::Form::WithInlineErrors::FormHasErrorsError)
        end

        it 'bypass the auto-error-validation when passing :assert_valid => false' do
          subject.submit(:assert_valid => false)
        end
      end

      describe 'searches errors only in the form' do
        let(:html) {<<-HTML
          <form action="/articles" method="post" class="form-with-errors article-form">
            <label for="title">Title</label>
            <input type="text" name="title" id="title">

            <input type="submit" value="Save">
          <form>
          <div class="error">
            this is another error.
          </div>
        HTML
        }

        it '#assert_has_no_errors passes' do
          subject.assert_has_no_errors
        end
      end

      describe 'without errors' do
        let(:html) {<<-HTML
          <form action="/articles" method="post" class="form-without-errors article-form">
            <label for="title">Title</label>
            <input type="text" name="title" id="title">

            <input type="submit" value="Save">
          <form>
        HTML
        }

        it '#assert_has_no_errors passes' do
          subject.assert_has_no_errors
        end

        it 'allows you to submit the form' do
          subject.submit
        end
      end

      describe 'with invalid label' do
        let(:html) {<<-HTML
          <form action="/articles" method="post" class="form-without-errors article-form">
            <label for="title">Title</label>
            <input type="submit" value="Save">
          <form>
        HTML
        }

        it "#attributes lists the field with a blank value" do
          subject.attributes.must_equal({"Title"=>""})
        end
      end
    end
  end
end
