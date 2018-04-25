require 'base64'

def create_es_cert_file(cert)
  begin
    es_cert_file = File.new('elasticsearch_cert.pem', 'w')
    es_cert_file.write(cert)
    es_cert_file.close
  rescue StandardError => e
    Rails.logger.fatal 'Failed to write elasticsearch certificate. Exiting'
    Rails.logger.fatal e
    exit
  end
  es_cert_file
end

def es_config_from_vcap
  begin
    vcap = JSON.parse(Rails.configuration.elasticsearch['vcap_services'])
    es_servers = vcap['elasticsearch'][0]['credentials']['uris'].map do |uri|
      uri.chomp('/')
    end
    es_cert = Base64.decode64(vcap['elasticsearch'][0]['credentials']['ca_certificate_base64'])
  rescue StandardError => e
    Rails.logger.fatal 'Failed to extract ES creds from VCAP_SERVICES. Exiting'
    Rails.logger.fatal Rails.configuration.elasticsearch['vcap_services']
    Rails.logger.fatal e
    exit
  end

  es_cert_file = create_es_cert_file(es_cert)

  {
    host: es_servers,
    transport_options: {
      request: {
        timeout: Rails.configuration.elasticsearch['elastic_timeout']
      },
      ssl: {
        ca_file: es_cert_file.path
      }
    }
  }
end

def es_config_from_host
  {
    host: Rails.configuration.elasticsearch['host'],
    transport_options: {
      request: {
        timeout: Rails.configuration.elasticsearch['elastic_timeout']
      }
    }
  }
end

if Rails.configuration.elasticsearch['host']
  config = es_config_from_host
elsif Rails.configuration.elasticsearch['vcap_services']
  config = es_config_from_vcap
else
  Rails.logger.fatal "No elasticsearch environment variables found"
  config = nil
end

ELASTIC = Elasticsearch::Client.new(config)
Elasticsearch::Model.client = ELASTIC
