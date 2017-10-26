require 'base64'

CONFIG_PATH = Rails.root.join('config', 'elasticsearch.yml')
TEMPLATE = ERB.new File.new(CONFIG_PATH).read

begin
  ELASTIC_CONFIG = YAML.load(TEMPLATE.result(binding))[ENV['RAILS_ENV']]
rescue => e
  Rails.logger.fatal 'Failed to parse elasticsearch yaml configuration. Exiting'
  Rails.logger.fatal e
  exit
end

def log(server, filepath)
  Rails.logger.info "Configuring Elasticsearch on PAAS.\n
  Elasticsearch host: #{server}\n
  Elasticsearch cert file path: #{filepath}"
end

def create_es_cert_file(cert)
  begin
    es_cert_file = File.new('elasticsearch_cert.pem', 'w')
    es_cert_file.write(cert)
    es_cert_file.close
  rescue => e
    Rails.logger.fatal 'Failed to write elasticsearch certificate. Exiting'
    Rails.logger.fatal e
    exit
  end
  es_cert_file
end

def es_config_from_vcap
  begin
    vcap = JSON.parse(ELASTIC_CONFIG['vcap_services'])
    es_server = vcap['elasticsearch'][0]['credentials']['uri'].chomp('/')
    es_cert = Base64.decode64(vcap['elasticsearch'][0]['credentials']['ca_certificate_base64'])
  rescue => e
    Rails.logger.fatal 'Failed to extract ES creds from VCAP_SERVICES. Exiting'
    Rails.logger.fatal ELASTIC_CONFIG['vcap_services']
    Rails.logger.fatal e
    exit
  end
  es_cert_file = create_es_cert_file(es_cert)
  log(es_server, es_cert_file.path)

  {
    host: es_server,
    transport_options: {
      request: {
        timeout: ELASTIC_CONFIG['elastic_timeout']
      },
      ssl: {
        ca_file: es_cert_file.path
      }
    }
  }
end

def es_config_from_host
  {
    host: ELASTIC_CONFIG['host'],
    transport_options: {
      request: {
        timeout: ELASTIC_CONFIG['elastic_timeout']
      }
    }
  }
end

if ELASTIC_CONFIG.has_key?('host')
  config = es_config_from_host
elsif ELASTIC_CONFIG.has_key?('vcap_services')
  config = es_config_from_vcap
else
  Rails.logger.fatal "No elasticsearch environment variables found"
  config = nil
end

ELASTIC = Elasticsearch::Client.new(config)
Elasticsearch::Model.client = ELASTIC
