module ResponseMacros

  def given_the_html(html)
    before do
      Capybara.app = lambda do |env|
        [200, {}, html]
      end
      visit '/'
    end
  end

end
