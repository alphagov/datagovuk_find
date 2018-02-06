require "simplecov"
require 'webmock/rspec'

SimpleCov.start

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

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

def delete_index
  if Rails.env == "test"
    begin
      ELASTIC.indices.delete index: "datasets-test"
    rescue
      Rails.logger.debug("No test search index to delete")
    end
  end
end

def create_index
  if Rails.env == "test"
    begin
      Rails.logger.info("Creating datasets-test index")

      ELASTIC.indices.create(
        index: "datasets-test",
        body: {
          settings: index_settings,
          mappings: index_mappings
        }
      )
    rescue
      Rails.logger.debug("Could not create datasets-test index")
    end
  end
end

def index_settings
  {
    analysis: {
      normalizer: {
        lowercase_normalizer: {
          type: "custom",
          filter: "lowercase"
        }
      }
    }
  }
end

def index_mappings
  {
    dataset: {
      properties: {
        name: {
          type: "string",
          index: "not_analyzed"
        },
        legacy_name: {
          type: 'string',
          index: 'not_analyzed'
        },
        uuid: {
          type: "string",
          index: "not_analyzed"
        },
        short_id: {
          type: 'string',
          index: 'not_analyzed'
        },
        location1: {
          type: 'string',
          fields: {
            raw: {
              type: 'string',
              index: 'not_analyzed'
            }
          }
        },
        topic: {
          type: 'nested',
          properties: {
            title: {
              type: 'string',
              fields: {
                raw: {
                  type: 'string',
                  index: 'not_analyzed'
                }
              }
            }
          }
        },
        organisation: {
          type: "nested",
          properties: {
            title: {
              type: "string",
              fields: {
                raw: {
                  type: "string",
                  index: "not_analyzed"
                }
              }
            }
          }
        },
        datafiles: {
          type: "nested",
          properties: {
            format: {
              type: "keyword",
              normalizer: "lowercase_normalizer"
            }
          }
        },
        docs: {
          type: "nested",
          properties: {
            format: { type: "keyword" }
          }
        }
      }
    }
  }
end
