require 'yaml'
require 'zendesk_api'

def load_config_file
  zendesk_config_path = Rails.root.join('config', 'zendesk.yml')
  zendesk_template = ERB.new File.new(zendesk_config_path).read

  begin
    zendesk_config = YAML.load(zendesk_template.result(binding))[ENV['RAILS_ENV']]
  rescue => e
    Rails.logger.fatal 'Failed to parse zendesk yaml configuration. Exiting'
    Rails.logger.fatal e
    exit
  end
  zendesk_config
end

def zendesk_config_from_vcap
  load_config_file
  config = {}
  begin
    vcap = JSON.parse(zendesk_config['vcap_services'])
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
    Rails.logger.debug zendesk_config['vcap_services']
    Rails.logger.fatal e
    raise e
  end
  config
end

def build_zendesk_client(username, password, api_key, end_point)
  ZendeskAPI::Client.new do |config|
    config.username = username
    config.token = api_key
    config.password = password
    config.url = end_point
  end
end

if Rails.env.production?
  username = zendesk_config_from_vcap['username']
  password = zendesk_config_from_vcap['password']
  api_key = zendesk_config_from_vcap['api_key']
  end_point = zendesk_config_from_vcap['end_point']
  GDS_ZENDESK_CLIENT = build_zendesk_client(username, password, api_key, end_point)
end

if Rails.env.test?
  zendesk_config = load_config_file
  username = zendesk_config['username']
  password = zendesk_config['password']
  api_key = zendesk_config['api_key']
  end_point = zendesk_config['end_point']
  GDS_ZENDESK_CLIENT = build_zendesk_client(username, password, api_key, end_point)
end

if Rails.env.development? || Rails.env.staging?
  GDS_ZENDESK_CLIENT = ZendeskDummyClient.new
end
