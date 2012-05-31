require 'integration/spec_helper'

require 'corner_stones/table_form'

describe CornerStones::TableForm do
  given_the_html <<-HTML
<form action="/movies" method="post" class="movie-form">
  <table class="movies">
    <thead>
      <tr>
        <th>Title</th>
        <th>Genre</th>
        <th>Actors</th>
        <th>Duration</th>
        <th>Extras</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>Pirates of the Carribean</td>
        <td>Action</td>
        <td>Jonny Depp</td>
        <td><input type="text" name="duration1" id="duration1"></td>
        <td>
          <select name="extras1" id="extras1">
            <option value="1">No extras</option>
            <option value="2">Special Scenes</option>
          </select>
        </td>
      </tr>
      <tr>
        <td>Pirates of the Carribean</td>
        <td>Tragedy</td>
        <td>David Hasselhoff</td>
        <td><input type="text" name="duration3" id="duration3"></td>
        <td>
          <select name="extras3" id="extras3">
            <option value="1">No extras</option>
            <option value="2">Special Scenes</option>
          </select>
        </td>
      </tr>
      <tr>
        <td>As it is in heaven</td>
        <td>Comedy</td>
        <td>Michael Moore</td>
        <td><input type="text" name="duration2" id="duration2"></td>
        <td>
          <select name="extras2" id="extras2">
            <option value="1">No extras</option>
            <option value="2">Special Scenes</option>
          </select>
        </td>
      </tr>
    </tbody>
  </table>
  <input type="submit" name="button" value="Save">
  <input type="submit" name="button" value="Save movies">
</form>
HTML

  subject { CornerStones::TableForm.new('.movie-form') }

  it 'detects columns with input fields' do
    subject.input_columns.must_equal ['Duration', 'Extras']
  end

  it 'allows you to fill a single row' do
    subject.fill_in_row({'Title' => 'As it is in heaven'}, :with => {'Duration' => '112 min', 'Extras' => 'Special Scenes'})

    subject.row('Title' => 'As it is in heaven')['Duration'].must_equal '112 min'
    subject.row('Title' => 'As it is in heaven')['Extras'].must_equal '2'
  end

  it 'allows you to submit the form' do
    subject.submit

    current_path.must_equal '/movies'
    page.driver.request.post?.must_equal true
  end

  it 'you can supply the submit-button text with the :button option' do
    subject.submit(:button => 'Save movies')

    page.driver.request.params['button'].must_equal 'Save movies'
  end

  it 'allows you to retrieve the current values of the form fields' do
    subject.fill_in_row({'Title' => 'Pirates of the Carribean'}, :with => {'Duration' => '120 min', 'Extras' => 'No extras'})
    subject.fill_in_row({'Title' => 'As it is in heaven'}, :with => {'Duration' => '108 min', 'Extras' => 'Special Scenes'})

    subject.row('Title' => 'Pirates of the Carribean', 'Genre' => 'Action')['Actors'].must_equal 'Jonny Depp'
    subject.row('Title' => 'Pirates of the Carribean', 'Genre' => 'Action')['Duration'].must_equal '120 min'
    subject.row('Title' => 'Pirates of the Carribean', 'Genre' => 'Action')['Extras'].must_equal '1'
    subject.row('Title' => 'Pirates of the Carribean', 'Genre' => 'Tragedy')['Actors'].must_equal 'David Hasselhoff'
    subject.row('Title' => 'Pirates of the Carribean', 'Genre' => 'Tragedy')['Duration'].must_equal nil
    subject.row('Title' => 'Pirates of the Carribean', 'Genre' => 'Tragedy')['Extras'].must_equal '1'
    subject.row('Title' => 'As it is in heaven', 'Genre' => 'Comedy')['Actors'].must_equal 'Michael Moore'
    subject.row('Title' => 'As it is in heaven', 'Genre' => 'Comedy')['Duration'].must_equal '108 min'
    subject.row('Title' => 'As it is in heaven', 'Genre' => 'Comedy')['Extras'].must_equal '2'
  end

  it 'fills the first matching row if the row cannot be uniquely identified' do
    subject.fill_in_row({'Title' => 'Pirates of the Carribean'}, :with => {'Duration' => 'too long'})

    subject.row('Title' => 'Pirates of the Carribean', 'Genre' => 'Action')['Duration'].must_equal 'too long'
    subject.row('Title' => 'Pirates of the Carribean', 'Genre' => 'Tragedy')['Duration'].must_equal nil
  end

  it 'you can not fill in columns without input fields' do
    lambda do
      subject.fill_in_row({'Title' => 'Pirates of the Carribean'}, :with => {'No Field' => 'Cant fill in'})
    end.must_raise(CornerStones::TableForm::MissingInputError)
  end

  describe 'cucumber table support' do
    it 'enables you to fill in values from a cucumber table' do
      cucumber_table_hashes = [
                               {'Title' => 'Pirates of the Carribean', 'Genre' => 'Tragedy', 'Duration' => '140 min'},
                               {'Title' => 'As it is in heaven', 'Extras' => 'Special Scenes'}
                              ]
      subject.fill_in_table(cucumber_table_hashes)

      subject.row('Title' => 'Pirates of the Carribean', 'Genre' => 'Tragedy')['Duration'].must_equal '140 min'
      subject.row('Title' => 'As it is in heaven')['Extras'].must_equal '2'
    end
  end

end
