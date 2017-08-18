CONFIG_PATH = "#{Rails.root}/config/elasticsearch.yml"
TEMPLATE = ERB.new File.new(CONFIG_PATH).read
ELASTIC_CONFIG = YAML.load(TEMPLATE.result(binding))[ENV['RAILS_ENV']]

config = {
  host: ELASTIC_CONFIG['host'],
  transport_options: {
    request: {
      timeout: 5
    }
  },
  send_get_body_as: 'POST'
}

ELASTIC = Elasticsearch::Client.new(config)
Elasticsearch::Model.client = ELASTIC
