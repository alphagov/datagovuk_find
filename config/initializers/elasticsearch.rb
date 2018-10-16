es_config = Rails.configuration.elasticsearch

host = es_config["host"]

if host.blank?
  vcap = JSON.parse(es_config["vcap_services"])
  host = vcap.dig("elasticsearch", 0, "credentials", "uri")
end

raise StandardError.new("No elasticsearch environment variables found") if host.blank?

Elasticsearch::Model.client = Elasticsearch::Client.new(
  host: host,
  transport_options: {
    request: {
      timeout: es_config.fetch("elastic_timeout"),
    },
    ssl: {
      verify: es_config.fetch("verify_ssl", true),
    },
  },
)
