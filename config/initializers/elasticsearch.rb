CONFIG_PATH = "#{Rails.root}/config/elasticsearch.yml"
ELASTIC_CONFIG = YAML.load_file(CONFIG_PATH)[Rails.env]

config = {
  host: ELASTIC_CONFIG['host'],
  transport_options: {
    request: {
      timeout: ELASTIC_CONFIG['transport_options']['request']['timeout']
    }
  }
}

ELASTIC = Elasticsearch::Client.new(config)
Elasticsearch::Model.client = ELASTIC
