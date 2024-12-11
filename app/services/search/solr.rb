module Search
  class Solr
    RESULTS_PER_PAGE = 20

    def self.search(params)
      query_param = params.fetch("q", "").squish
      @page = params["page"]
      sort_param = params["sort"]
      @page && @page.to_i.positive? ? @page.to_i : 1

      get_organisations
      
      build_term_query(query_param)
      @sort_query = "metadata_modified desc" if sort_param == "recent"
      build_filter_query(params)

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

    def self.build_term_query(query_param)
      @query = query_param.present? ? "title:\"#{query_param}\" OR notes:\"#{query_param}\" AND NOT site_id:dgu_organisations" : "*:*"
    end

    def self.build_filter_query(params)
      publisher_param = params.dig(:filters, :publisher)
      topic_param = params.dig(:filters, :topic)
      format_param = params.dig(:filters, :format)
      licence_param = params.dig(:filters, :licence_code)

      filter_query = ["state:active"]
      filter_query << publisher_filter(publisher_param) if publisher_param.present?
      filter_query << topic_filter(topic_param) if topic_param.present?
      filter_query << format_filter(format_param) if format_param.present?
      filter_query << licence_filter(licence_param) if licence_param.present?

      @filter_query = filter_query
    end

    def self.publisher_filter(organisation)
      "organization:#{@organisations_list[organisation]}"
    end

    def self.topic_filter(topic)
      "extras_theme-primary:\"#{topic.parameterize(separator: '-')}\""
    end

    FORMAT_MAPPINGS = {
      "CSV" => ["CSV", ".csv", "csv", "CSV ", "csv.", ".CSV", "https://www.iana.org/assignments/media-types/text/csv"],
      "ESRI REST" => ["Esri REST", "ESRI REST API"],
      "GEOJSON" => %w[GeoJSON geojson],
      "HTML" => %w[HTML html .html],
      "JSON" => ["JSON", "json1.0", "json2.0", "https://www.iana.org/assignments/media-types/application/json"],
      "KML" => %w[KML kml],
      "PDF" => %w[PDF .pdf pdf],
      "SHP" => %w[SHP],
      "WFS" => ["WFS", "OGC WFS", "ogc wfs", "wfs"],
      "WMS" => ["WMS", "OGC WMS", "ogc wfs", "wms"],
      "XLS" => %w[XLS xls .xls],
      "XML" => %w[XML],
      "ZIP" => %w[ZIP Zip https://www.iana.org/assignments/media-types/application/zip zip .zip],
    }.freeze

    def self.format_filter(format)
      return other_formats_filter_query if format == "Other"

      FORMAT_MAPPINGS[format].map { |f| "res_format:\"#{f}\"" }.join("OR")
    end

    OGL_IDS = ["uk-ogl", /OGL-UK-*/, "ogl"].freeze

    def self.licence_filter(licence)
      return "license_id:(#{OGL_IDS.map { |id| id.is_a?(Regexp) ? id.source : id }.join(' ')})" if licence == "uk-ogl"

      "license_id:\"#{licence}\""
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
        rows: RESULTS_PER_PAGE,
        fl: field_list,
        sort: @sort_query,
      }
    end

    def self.query_solr_with_facets
      client.get "select", params: {
        q: @query,
        fq: @filter_query,
        start: @page,
        rows: RESULTS_PER_PAGE,
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

    def self.other_formats_filter_query
      query_parts = FORMAT_MAPPINGS.values.flatten.map do |format|
        "-res_format:\"#{format}\""
      end
      query_parts.join("")
    end
  end
end
