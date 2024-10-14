module Search
  class Solr
    def self.search(params)
      query_param = params.fetch("q", "").squish
      page = params["page"]
      sort_param = params["sort"]
      page && page.to_i.positive? ? page.to_i : 1

      solr_client = client

      query = "*:*" if query_param.empty?

      sort_query = "metadata_modified desc" if sort_param == "recent"

      solr_client.get "select", params: {
        q: query,
        start: page,
        rows: 20,
        fl: field_list,
        sort: sort_query,
      }
    end

    def self.get_by_uuid(uuid:)
      solr_client = client

      solr_client.get "select", params: {
        q: "*:*",
        fq: "id:#{uuid}",
        fl: field_list,
      }
    end

    def self.get_organisation(name)
      solr_client = client

      solr_client.get "select", params: {
        q: "*:*",
        fq: [
          "site_id:dgu_organisations",
          "name:#{name}",
        ],
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
        metadata_created
        extras_theme-primary
        validated_data_dict
      ].freeze
    end

    def self.client
      @client ||= RSolr.connect(url: ENV["SOLR_URL"])
    end
  end
end
