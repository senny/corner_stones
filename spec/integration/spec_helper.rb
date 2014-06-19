require "bundler/setup"

require 'minitest/autorun'
require 'minitest/spec'

require 'capybara'
require 'capybara/dsl'

Capybara.default_wait_time = 0

require 'integration/support/response_macros'

class Minitest::Test
  extend ResponseMacros
  include Capybara::DSL
end
