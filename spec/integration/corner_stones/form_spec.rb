require 'integration/spec_helper'

require 'corner_stones/form'
require 'corner_stones/form/with_inline_errors'

describe CornerStones::Form do

  given_the_html <<-HTML
    <form action="/articles" method="post" class="article-form">
      <label for="title">Title</label>
      <input type="text" name="title" id="title">

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

      <input type="submit" name="button" value="Save">
      <input type="submit" name="button" value="Save Article">

    </form>
  HTML

  subject { CornerStones::Form.new('.article-form') }

  it 'allows you to fill in the form' do
    subject.fill_in_with('Title' => 'Domain Driven Design',
                         'Author' => 'Eric Evans',
                         'Body' => '...',
                         'File' => 'spec/files/hadoken.png',
                         'Checkbox' => true)

    find('#title').value.must_equal 'Domain Driven Design'
    find('#author').value.must_equal '2'
    find('#body').value.must_equal '...'
    find('#file').value.must_equal 'spec/files/hadoken.png'
    find('#check').value.must_equal '1'
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
                      'Author' => 'Eric Evans',
                      'Body' => 'Some Content...',
                      'File' => 'spec/files/hadoken.png',
                      'Checkbox' => true})

    current_path.must_equal '/articles'
    page.driver.request.post?.must_equal true

    page.driver.request.params.must_equal({"title" => "Domain Driven Design", "author" => "2", "body" => "Some Content...", "file" => "hadoken.png", 'check' => '1', 'button' => 'Save'})
  end

  it 'allows you to process (fill_in_with + submit) the form using an alternate button' do
    subject.process(:fill_in => {'Title' => 'Domain Driven Design',
                      'Author' => 'Eric Evans',
                      'Body' => 'Some Content...'},
                    :button => 'Save Article')

    page.driver.request.params['button'].must_equal('Save Article')
  end

  describe 'form with an unknown field type' do
    given_the_html <<-HTML
      <form action="/articles" method="post" class="form-with-errors article-form">
        <label for="unknown">Unknown</label>
        <a id="unknown">Link</a>
      </form>
HTML
    it 'raises an error when filling the form' do
      assert_raises(CornerStones::Form::UnknownFieldError) { subject.fill_in_with('Unknown' => '123456') }
    end
  end

  describe 'mixins' do
    describe 'form errors' do

      before do
        subject.extend(CornerStones::Form::WithInlineErrors)
      end

      describe 'with errors' do
        given_the_html <<-HTML
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

          <input type="submit" value="Save">

          </form>
        HTML

        it 'assembles the errors into a hash' do
          subject.errors.must_equal([{"Field" => "Author", "Value" => "1", "Error" => "The author is not active"},
                                     {"Field" => "Body", "Value" => "...", "Error" => "invalid body"}])
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

      describe 'without errors' do
        given_the_html <<-HTML
          <form action="/articles" method="post" class="form-without-errors article-form">
            <label for="title">Title</label>
            <input type="text" name="title" id="title">

            <input type="submit" value="Save">
          <form>
        HTML
      end

      it '#assert_has_no_errors passes' do
        subject.assert_has_no_errors
      end

      it 'allows you to submit the form' do
        subject.submit
      end
    end
  end
end
