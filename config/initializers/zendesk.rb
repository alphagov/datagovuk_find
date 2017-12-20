require 'zendesk_api'

def zendesk_config_from_vcap
  zendesk_config = {}
  begin
    vcap = JSON.parse(ENV["VCAP_SERVICES"])
    vcap['user-provided'].each do |elem|
      if (elem.has_key? 'credentials') && (elem['credentials'].has_key? 'ZENDESK_USERNAME')
        zendesk_config["username"] = elem['credentials']['ZENDESK_USERNAME']
        zendesk_config["password"] = elem['credentials']['ZENDESK_PASSWORD']
        zendesk_config["api_key"] = elem['credentials']['ZENDESK_API_KEY']
        zendesk_config["end_point"] = elem['credentials']['ZENDESK_END_POINT']
      end
    end
  rescue => e
    Rails.logger.fatal 'Failed to extract zendesk creds from VCAP_SERVICES. Exiting'
    Rails.logger.fatal vcap
    Rails.logger.fatal e
    raise e
  end
  zendesk_config
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
  config = zendesk_config_from_vcap
  username = config['username']
  password = config['password']
  api_key = config['api_key']
  end_point = config['end_point']
  GDS_ZENDESK_CLIENT = build_zendesk_client(username, password, api_key, end_point)
end

if Rails.env.test?
  username = 'test-user@mail.com'
  password = 'your-fake-zendesk-password-here'
  api_key = '123abc'
  end_point = 'https://test_zendesk_url.com/api/v2'
  GDS_ZENDESK_CLIENT = build_zendesk_client(username, password, api_key, end_point)
end

if Rails.env.development? || Rails.env.staging?
  GDS_ZENDESK_CLIENT = ZendeskDummyClient.new
end
