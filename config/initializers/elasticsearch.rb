def es_config_from_vcap
  begin
    vcap = JSON.parse(Rails.configuration.elasticsearch['vcap_services'])
    es_server = vcap['elasticsearch'][0]['credentials']['uri']
  rescue StandardError => e
    Rails.logger.fatal "Failed to extract ES creds from VCAP_SERVICES. Exiting"
    Rails.logger.fatal Rails.configuration.elasticsearch['vcap_services']
    Rails.logger.fatal e
    exit
  end

  es_config_from_host(es_server)
end

def es_config_from_host(config)
  {
    host: config.fetch("host"),
    transport_options: {
      request: {
        timeout: config.fetch("elastic_timeout"),
      },
      ssl: {
        verify: config.fetch("verify_ssl", true),
      },
    },
  }
end


if Rails.configuration.elasticsearch['host']
  config = es_config_from_host(Rails.configuration.elasticsearch)
elsif Rails.configuration.elasticsearch['vcap_services']
  config = es_config_from_vcap
else
  Rails.logger.fatal "No elasticsearch environment variables found"
  config = nil
end

ELASTIC = Elasticsearch::Client.new(config)
Elasticsearch::Model.client = ELASTIC
