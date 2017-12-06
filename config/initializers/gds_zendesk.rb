require 'yaml'
require 'gds_zendesk/client'
require 'gds_zendesk/dummy_client'

ZENDESK_CONFIG_PATH = Rails.root.join('config', 'zendesk.yml')
ZENDESK_TEMPLATE = ERB.new File.new(ZENDESK_CONFIG_PATH).read

begin
  ZENDESK_CONFIG = YAML.load(ZENDESK_TEMPLATE.result(binding))[ENV['RAILS_ENV']]
rescue => e
  Rails.logger.fatal 'Failed to parse zendesk yaml configuration. Exiting'
  Rails.logger.fatal e
  exit
end

def zendesk_config_from_vcap
  config = {}
  begin
    vcap = JSON.parse(ZENDESK_CONFIG['vcap_services'])
    config["username"] = vcap['user-provided'][0]['credentials']['ZENDESK_USERNAME']
    config["password"] = vcap['user-provided'][0]['credentials']['ZENDESK_PASSWORD']
  rescue => e
    Rails.logger.fatal 'Failed to extract zendesk creds from VCAP_SERVICES. Exiting'
    Rails.logger.fatal ZENDESK_CONFIG['vcap_services']
    Rails.logger.fatal e
  exit
  end
  config
end

username = zendesk_config_from_vcap['username']
password = zendesk_config_from_vcap['password']

GDS_ZENDESK_CLIENT = if Rails.env.production?
  GDSZendesk::Client.new(username: username, password: password, logger: Rails.logger)
else
  GDSZendesk::DummyClient.new(logger: Rails.logger)
end
