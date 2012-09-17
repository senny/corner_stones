require 'integration/spec_helper'

require 'corner_stones/table'
require 'corner_stones/table/deletable_rows'
require 'corner_stones/table/selectable_rows'

describe CornerStones::Table do

  stub_capybara_response
  let(:html) { <<-HTML
    <table class="articles">
      <thead>
        <tr>
          <th>ID</th>
          <th>Title</th>
          <th>Author</th>
        </tr>
      </thead>
        <tbody>
          <tr>
            <td>1</td>
            <td>Clean Code</td>
            <td>Robert C. Martin</td>
          </tr>
          <tr>
            <td>2</td>
            <td>Domain Driven Design</td>
            <td>Eric Evans</td>
          </tr>
        </tbody>
        </table
  HTML
  }

  subject { CornerStones::Table.new('.articles') }

  describe 'headers' do
    it 'get detected automatically from the "th" tags' do
      subject.headers.must_equal ['ID', 'Title', 'Author']
    end

    it 'can be supplied with the :headers option' do
      table_with_custom_headers = CornerStones::Table.new('.articles', :headers => ['A-ID', 'strTitle', 'strAuthor'])
      table_with_custom_headers.headers.must_equal ['A-ID', 'strTitle', 'strAuthor']
    end
  end

  describe "data" do
    it 'is read into an array of hashes ({header} => {data})' do
      expected_data = [{'ID' => '1', 'Title' => 'Clean Code', 'Author' => 'Robert C. Martin'},
                       { 'ID' => '2', 'Title' => 'Domain Driven Design', 'Author' => 'Eric Evans'}]

      subject.rows.map {|r|
        r.attributes.reject do |key, _value|
          !expected_data.first.has_key?(key)
        end
      }.must_equal(expected_data)
    end

    it 'a row can be accessed with a single key' do
      actual = subject.row('Title' => 'Domain Driven Design')
      actual['Author'].must_equal('Eric Evans')
    end

    it 'a row can be accessed with multiple keys' do
      actual = subject.row('ID' => '1', 'Author' => 'Robert C. Martin')
      actual['Title'].must_equal('Clean Code')
    end

    it 'It raises an Exception when no Row was found' do
      lambda do
        subject.row('ID' => '3')
      end.must_raise(CornerStones::Table::MissingRowError)
    end

    it 'extracts the Capybara-Element for the table row' do
      subject.row('ID' => '1').node.path.must_equal('/html/body/table/tbody/tr[1]')
    end
  end

  describe 'custom tables' do
    describe 'inline headers' do
      let(:html) { <<-HTML
        <table class="articles">
          <tbody>
            <tr>
              <th>Clean Code</th>
              <td>Robert C. Martin</td>
            </tr>
            <tr>
              <th>Domain Driven Design</th>
              <td>Eric Evans</td>
            </tr>
          </tbody>
       </table>
      HTML
      }

      subject { CornerStones::Table.new('.articles', :headers => ['Book', 'Author'], :data_selector => 'th,td') }

      it 'the option :data_selector can be used to widen the data to other elements' do
        expected_data = [{ 'Book' => 'Clean Code',
                           'Author' => 'Robert C. Martin'},
                         { 'Book' => 'Domain Driven Design',
                           'Author' => 'Eric Evans'}]
        subject.rows.map {|r|
          r.attributes.reject do |key, _value|
            !expected_data.first.has_key?(key)
          end
        }.must_equal(expected_data)
      end

    end
  end

  describe 'colspans' do
    let(:html) { <<-HTML
      <table class="articles">
        <thead>
          <tr>
            <th>ID</th>
            <th>Title</th>
            <th>Author</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>1</td>
            <td colspan="2">Clean Code</td>
          </tr>
        </tbody>
      </table>
HTML
    }

    it 'ignores empty cells' do
      expected_data = [{'ID' => '1', 'Title' => 'Clean Code', 'Author' => nil}]
      actual = subject.rows

      actual = actual.map {|row| row.attributes.reject {|key, _value| !expected_data.first.has_key?(key)}}
      actual.must_equal(expected_data)
    end
  end

  describe 'mixins' do
    describe 'deletable rows' do
      let(:html) {<<-HTML
        <table class="articles">
          <thead>
            <tr>
              <th>ID</th>
              <th>Title</th>
              <th>Author</th>
            </tr>
          </thead>
            <tbody>
              <tr>
                <td>1</td>
                <td>Clean Code</td>
                <td>Robert C. Martin</td>
                <td><a class="delete-action" href="/delete/clean_code">X</a></td>
              </tr>
              <tr>
                <td>2</td>
                <td>Domain Driven Design</td>
                <td>Eric Evans</td>
                <td><a class="delete-action" href="/delete/domain_driven_design">X</a></td>
              </tr>
              <tr>
                <td>3</td>
                <td>Pro Git</td>
                <td>Scott Chacon</td>
              </tr>
            </tbody>
          </table>
    HTML
      }
      before do
        subject.extend(CornerStones::Table::DeletableRows)
      end

      it 'allows you to trigger a deletion with a row selector' do
        subject.row('Title' => 'Domain Driven Design').delete
        current_path.must_equal '/delete/domain_driven_design'
      end

      it 'raises an error when a the target row can not be found' do
        begin
          subject.row('ID' => '3').delete
        rescue => e
          e.message.must_match /^The row '.*' does not have a delete-link$/
        end
      end

      it 'the deprecated method #delete_row still works' do
        errors = StringIO.new
        original_stderr = $stderr
        $stderr = errors

        subject.delete_row('Title' => 'Domain Driven Design')

        $stderr = original_stderr
        current_path.must_equal '/delete/domain_driven_design'
        errors.string.must_equal "[DEPRECATION] `delete_row` is deprecated. Please use `row(row_spec).delete` instead.\n"
      end

    end

    describe 'selectable rows' do
      let(:html) { <<-HTML
        <table class="articles">
          <thead>
            <tr>
              <th>ID</th>
              <th>Title</th>
              <th>Author</th>
            </tr>
          </thead>
            <tbody>
              <tr data-selected-url="/articles/clean_code">
                <td>1</td>
                <td>Clean Code</td>
                <td>Robert C. Martin</td>
              </tr>
              <tr data-selected-url="/articles/domain_driven_design">
                <td>2</td>
                <td>Domain Driven Design</td>
                <td>Eric Evans</td>
              </tr>
            </tbody>
          </table>
    HTML
      }

      before do
        subject.extend(CornerStones::Table::SelectableRows)
      end

      it 'allows you to select a row' do
        subject.row('ID' => '1').select
        current_path.must_equal '/articles/clean_code'
      end

      it 'the deprecated method #select_row still works' do
        errors = StringIO.new
        original_stderr = $stderr
        $stderr = errors

        subject.select_row('ID' => '1')

        $stderr = original_stderr
        current_path.must_equal '/articles/clean_code'
        errors.string.must_equal "[DEPRECATION] `select_row` is deprecated. Please use `row(row_spec).select` instead.\n"
      end
    end

    describe 'whitespace filter' do
      let(:html) { <<-HTML
        <table class="articles">
          <thead>
            <tr>
              <th>Author</th>
            </tr>
          </thead>
            <tbody>
              <tr data-selected-url="/articles/clean_code">
                <td>Robert C. Martin</td>
              </tr>
              <tr data-selected-url="/articles/domain_driven_design">
                <td>

                  Eric Evans

                </td>
              </tr>
            </tbody>
          </table>
    HTML
      }
      before do
        subject.extend(CornerStones::Table::WhitespaceFilter)
      end

      it 'strips whitespace from cell content' do
        subject.rows.map { |r| r['Author']}.must_equal ["Robert C. Martin", "Eric Evans"]
      end
    end
  end
end
