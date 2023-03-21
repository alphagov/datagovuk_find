es_config = Rails.configuration.elasticsearch

host = es_config[:host]

if host.blank?
  vcap = JSON.parse(es_config[:vcap_services])
  host = vcap.dig("opensearch", 0, "credentials", "uri")
end

raise StandardError, "No opensearch environment variables found" if host.blank?

Elasticsearch::Model.client = Elasticsearch::Client.new(
  host:,
  transport_options: {
    request: {
      timeout: es_config.fetch(:elastic_timeout),
    },
    ssl: {
      verify: es_config.fetch(:verify_ssl, true),
    },
  },
)
