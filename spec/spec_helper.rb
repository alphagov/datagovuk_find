require "simplecov"
require 'webmock/rspec'

SimpleCov.start
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.before(:each) do
    delete_index
    create_index
  end

  config.after(:each) do
    delete_index
  end

  config.order = :random
  Kernel.srand config.seed
end
