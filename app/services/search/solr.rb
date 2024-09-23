module Search
  class Solr
    def self.search(params)
      query_param = params.fetch("q", "").squish
      page = params["page"]
      page && page.to_i.positive? ? page.to_i : 1

      solr_client = client

      query = "*:*" if query_param.empty?

      solr_client.get "select", params: {
        q: query,
        start: page,
        rows: 20,
        fl: field_list,
      }
    end

    def self.field_list
      %w[
        id
        name
        title
        organization
        notes
        metadata_modified
        extras_theme-primary
        validated_data_dict
      ].freeze
    end

    def self.client
      @client ||= RSolr.connect(url: ENV["SOLR_URL"])
    end
  end
end
