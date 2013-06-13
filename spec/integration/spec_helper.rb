require "bundler/setup"

require 'minitest/autorun'
require 'minitest/spec'

require 'capybara'
require 'capybara/dsl'

Capybara.default_wait_time = 0

require 'integration/support/response_macros'

include ResponseMacros
include Capybara::DSL
