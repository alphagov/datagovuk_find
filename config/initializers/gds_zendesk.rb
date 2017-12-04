require 'yaml'
require 'gds_zendesk/client'
require 'gds_zendesk/dummy_client'

GDS_ZENDESK_CLIENT = if Rails.env.development? || Rails.env.test?
  GDSZendesk::DummyClient.new(logger: Rails.logger)
else
  config_yaml_file = File.join(Rails.root, 'config', 'zendesk.yml')
  config = YAML.load_file(config_yaml_file)[Rails.env]
  GDSZendesk::Client.new(username: config['username'], password: config['password'], logger: Rails.logger)
end
