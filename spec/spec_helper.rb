require "simplecov"
require 'webmock/rspec'
require 'factory_bot'

SimpleCov.start

WebMock.disable_net_connect!(allow_localhost: true)
FactoryBot.find_definitions

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.include FactoryBot::Syntax::Methods

  config.before(:each) do
    delete_index
    create_index
  end

  config.after(:each) do
    delete_index
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.profile_examples = 1
  config.order = :random
  Kernel.srand config.seed
end
