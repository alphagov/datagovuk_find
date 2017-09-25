require 'base64'
require 'tempfile'

CONFIG_PATH = Rails.root.join('config', 'elasticsearch.yml')
TEMPLATE = ERB.new File.new(CONFIG_PATH).read
ELASTIC_CONFIG = YAML.load(TEMPLATE.result(binding))[ENV['RAILS_ENV']]

def log(server, filepath)
  Rails.logger.info "Configuring Elasticsearch on PAAS.\n
  Elasticsearch host: #{server}\n
  Elasticsearch cert file path: #{filepath}"
end

def create_es_cert_file(cert)
  begin
    es_cert_file = Tempfile.new(%w(out .pem))
    es_cert_file.write(cert)
  ensure
    es_cert_file.close
  end
  es_cert_file
end


def es_config_production
  vcap = ELASTIC_CONFIG['vcap_services']

  es_server = vcap['elasticsearch'][0]['credentials']['uri'].chomp('/')
  es_cert = Base64.decode64(vcap['elasticsearch'][0]['credentials']['ca_certificate_base64'])
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
    },
    send_get_body_as: 'POST'
  }
end

def es_config_non_production
  {
    host: ELASTIC_CONFIG['host'],
    transport_options: {
      request: {
        timeout: ELASTIC_CONFIG['elastic_timeout']
      }
    },
    send_get_body_as: 'POST'
  }
end

config = ELASTIC_CONFIG['vcap_services'].present? ?
            es_config_production :
            es_config_non_production

ELASTIC = Elasticsearch::Client.new(config)
Elasticsearch::Model.client = ELASTIC
