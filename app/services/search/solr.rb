module Search
  class Solr
    def self.search(params)
      query_param = params.fetch("q", "").squish
      page = params["page"]
      sort_param = params["sort"]
      publisher_param = params.dig(:filters, :publisher)
      page && page.to_i.positive? ? page.to_i : 1

      solr_client = client

      query = query_param.present? ? "title:\"#{query_param}\" OR notes:\"#{query_param}\" AND NOT site_id:dgu_organisations" : "*:*"

      sort_query = "metadata_modified desc" if sort_param == "recent"
      filter_query = []
      filter_query << publisher_filter(publisher_param) if publisher_param.present?

      solr_client.get "select", params: {
        q: query,
        fq: filter_query,
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

    def self.publisher_filter(organisation)
      "organization:#{@organisations_list[organisation]}"
    end

    def self.get_organisations
      solr_client = client
      @organisations_list = {}

      query = solr_client.get "select", params: {
        q: "*:*",
        fq: [
          "site_id:dgu_organisations",
        ],
        fl: %w[title name],
        rows: 1600,
      }
      query["response"]["docs"].each do |org|
        @organisations_list.store(org["title"], org["name"])
      end

      @organisations_list
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
        extras_licence
      ].freeze
    end

    def self.client
      @client ||= RSolr.connect(url: ENV["SOLR_URL"])
    end
  end
end
