module Search
  class Solr
    def self.search(params)
      query_param = params.fetch("q", "").squish
      @page = params["page"]
      sort_param = params["sort"]
      publisher_param = params.dig(:filters, :publisher)
      topic_param = params.dig(:filters, :topic)
      format_param = params.dig(:filters, :format)
      licence_param = params.dig(:filters, :licence_code)
      @page && @page.to_i.positive? ? @page.to_i : 1

      get_organisations

      @query = query_param.present? ? "title:\"#{query_param}\" OR notes:\"#{query_param}\" AND NOT site_id:dgu_organisations" : "*:*"

      @sort_query = "metadata_modified desc" if sort_param == "recent"
      @filter_query = []
      @filter_query << publisher_filter(publisher_param) if publisher_param.present?
      @filter_query << topic_filter(topic_param) if topic_param.present?
      @filter_query << format_filter(format_param) if format_param.present?
      @filter_query << licence_filter(licence_param) if licence_param.present?

      query_param.empty? ? query_solr : query_solr_with_facets
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

    def self.topic_filter(topic)
      "extras_theme-primary:\"#{topic.parameterize(separator: '-')}\""
    end

    def self.format_filter(format)
      format = "GeoJSON" if format == "GEOJSON"
      "res_format:#{format}"
    end

    def self.licence_filter(licence)
      "license_id:#{licence}"
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
        fl: %w[title name],
      }
    end

    def self.query_solr
      client.get "select", params: {
        q: @query,
        fq: @filter_query,
        start: @page,
        rows: 20,
        fl: field_list,
        sort: @sort_query,
      }
    end

    def self.query_solr_with_facets
      client.get "select", params: {
        q: @query,
        fq: @filter_query,
        start: @page,
        rows: 20,
        fl: field_list,
        sort: @sort_query,
        facet: "true",
        "facet.field": %w[organization extras_theme-primary res_format],
        "facet.sort": "count",
        "facet.mincount": 1,
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
        res_format
        validated_data_dict
        extras_licence
      ].freeze
    end

    def self.client
      @client ||= RSolr.connect(url: ENV["SOLR_URL"])
    end
  end
end
