es_config = Rails.configuration.elasticsearch

host = es_config[:host]

if host.blank?
  vcap = JSON.parse(es_config[:vcap_services])
  host = vcap.dig("opensearch", 0, "credentials", "uri")
end

raise StandardError, "No opensearch environment variables found" if host.blank?

zero_false_or_no = /^[0fn]/i
elasticsearch_verify_ssl = !zero_false_or_no.match?(ENV["ELASTICSEARCH_VERIFY_SSL"])

Elasticsearch::Model.client = Elasticsearch::Client.new(
  host: host,
  transport_options: {
    request: {
      timeout: es_config.fetch(:elastic_timeout),
    },
    ssl: {
      verify: es_config.fetch(:verify_ssl, elasticsearch_verify_ssl),
    },
  },
)
