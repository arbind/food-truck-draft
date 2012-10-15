ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)

require "minitest/autorun"
require "minitest/rails"
require 'spork'

#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'
Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
end
Spork.each_run do
  # This code will be run each time you run your specs.
end
# restart spork if this file itself is changed

# Uncomment if you want Capybara in accceptance/integration tests
# require "minitest/rails/capybara"

# Uncomment if you want awesome colorful output
# require "minitest/pride"

class MiniTest::Rails::ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  # How to set this up for mongo?????
  # create_fixtures :all

  # Add more helper methods to be used by all tests here...
end

# Do you want all existing Rails tests to use MiniTest::Rails?
# Comment out the following and either:
# A) Change the require on the existing tests to `require "minitest_helper"`
# B) Require this file's code in test_helper.rb

# MiniTest::Rails.override_testunit!
