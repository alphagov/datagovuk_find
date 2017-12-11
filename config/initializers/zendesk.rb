require 'yaml'
require 'zendesk_api'

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
    vcap['user-provided'].each do |elem|
      if (elem.has_key? 'credentials') && (elem['credentials'].has_key? 'ZENDESK_USERNAME')
        config["username"] = elem['credentials']['ZENDESK_USERNAME']
        config["password"] = elem['credentials']['ZENDESK_PASSWORD']
        config["api_key"] = elem['credentials']['ZENDESK_API_KEY']
        config["end_point"] = elem['credentials']['ZENDESK_END_POINT']
      end
    end
  rescue => e
    Rails.logger.fatal 'Failed to extract zendesk creds from VCAP_SERVICES. Exiting'
    Rails.logger.fatal ZENDESK_CONFIG['vcap_services']
    Rails.logger.fatal e
    exit
  end
  config
end

if Rails.env.production?
  username = zendesk_config_from_vcap['username']
  password = zendesk_config_from_vcap['password']
  api_key = zendesk_config_from_vcap['api_key']
  end_point = zendesk_config_from_vcap['end_point']
end
if Rails.env.test?
  username = ZENDESK_CONFIG['username']
  password = ZENDESK_CONFIG['password']
  api_key = ZENDESK_CONFIG['api_key']
  end_point = ZENDESK_CONFIG['end_point']
end

GDS_ZENDESK_CLIENT =
  if Rails.env.production? || Rails.env.test?
    ZendeskAPI::Client.new do |config|
        config.username = username
        config.token = api_key
        config.password = password
        config.url = end_point
      end
  else
    ZendeskDummyClient.new
  end
