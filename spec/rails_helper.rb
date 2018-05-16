ENV['RAILS_ENV'] ||= 'test'

require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/rails'
require 'selenium/webdriver'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w(headless disable-gpu) }
  )

  Capybara::Selenium::Driver.new app, browser: :chrome, desired_capabilities: capabilities
end

Capybara.javascript_driver = :headless_chrome

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include Capybara::DSL
end
