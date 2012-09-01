require "bundler/setup"

require 'minitest/spec'
require 'minitest/autorun'

require 'capybara'
require 'capybara/dsl'

Capybara.default_wait_time = 0

require 'integration/support/response_macros'

include ResponseMacros
include Capybara::DSL
