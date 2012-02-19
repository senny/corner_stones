require 'integration/spec_helper'

require 'corner_stones/table'
require 'corner_stones/table/deletable_rows'
require 'corner_stones/table/selectable_rows'

describe CornerStones::Table do

  given_the_html <<-HTML
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
      subject.rows.must_equal [{'ID' => '1',
                                 'Title' => 'Clean Code',
                                 'Author' => 'Robert C. Martin'},
                               {'ID' => '2',
                                 'Title' => 'Domain Driven Design',
                                 'Author' => 'Eric Evans'}]
    end

    it 'a row can be accessed with a single key' do
      subject.row('Title' => 'Domain Driven Design').must_equal({ 'ID' => '2',
                                                                  'Title' => 'Domain Driven Design',
                                                                  'Author' => 'Eric Evans' })
    end

    it 'a row can be accessed with multiple keys' do
      subject.row('ID' => '1',
                  'Author' => 'Robert C. Martin').must_equal({'ID' => '1',
                                                               'Title' => 'Clean Code',
                                                               'Author' => 'Robert C. Martin'})
    end

    it 'nil is returned when no matching row was found' do
      subject.row('ID' => '3').must_equal(nil)
    end
  end

  describe 'custom tables' do
    describe 'inline headers' do
      given_the_html <<-HTML
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

      subject { CornerStones::Table.new('.articles', :headers => ['Book', 'Author'], :data_selector => 'th,td') }

      it 'the option :data_selector can be used to widen the data to other elements' do
        subject.rows.must_equal [{ 'Book' => 'Clean Code',
                                   'Author' => 'Robert C. Martin'},
                                 { 'Book' => 'Domain Driven Design',
                                   'Author' => 'Eric Evans'}]
      end

    end
  end

  describe 'mixins' do
    describe 'deletable rows' do
      given_the_html <<-HTML
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
                <td class="delete-action"><a href="/delete/clean_code">X</a></td>
              </tr>
              <tr>
                <td>2</td>
                <td>Domain Driven Design</td>
                <td>Eric Evans</td>
                <td class="delete-action"><a href="/delete/domain_driven_design">X</a></td>
              </tr>
            </tbody>
          </table>
    HTML

      before do
        subject.extend(CornerStones::Table::DeletableRows)
      end

      it 'it includes the "Delete-Link" object in the data' do
        subject.rows.each do |row|
          row['Delete-Link'].must_be_kind_of(Capybara::Node::Element)
        end
      end

      it 'allows you to trigger a deletion with a row selector' do
        subject.delete_row('Title' => 'Domain Driven Design')
        current_path.must_equal '/delete/domain_driven_design'
      end
    end

    describe 'selectable rows' do
      given_the_html <<-HTML
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

      before do
        subject.extend(CornerStones::Table::SelectableRows)
      end

      it 'it includes the "Selected-Link" object in the data' do
        subject.rows.map do |row|
          row['Selected-Link']
        end.must_equal ['/articles/clean_code', '/articles/domain_driven_design']
      end

      it 'allows you to select a row' do
        subject.select_row('ID' => '1')
        current_path.must_equal '/articles/clean_code'
      end
    end

  end
end
