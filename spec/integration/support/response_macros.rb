module ResponseMacros

  def stub_capybara_response
    before do
      Capybara.app = lambda do |env|
        [200, {}, html]
      end
      visit '/'
    end
  end

end
