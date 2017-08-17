config = {
  host: ENV.fetch("ES_HOST", "http://127.0.0.1:9200"),
  transport_options: {
    request: { timeout: 5 }
  },
  send_get_body_as: 'POST'
}

if File.exist?("config/elasticsearch.yml")
  config.merge!(YAML.load_file("config/elasticsearch.yml")[Rails.env].symbolize_keys)
end

ELASTIC = Elasticsearch::Client.new(config)
Elasticsearch::Model.client = ELASTIC
