module Search
  module Solr
    class Query
      MULTI_MATCH_FIELDS = %w[title notes].freeze

      def self.search(params)
        query_param = params.fetch("q", "").squish
        sort_param =  params["sort"]
        page = params["page"]
        page && page.to_i.positive? ? page.to_i : 1

        publisher_param = params.dig(:filters, :publisher)
        location_param =  params.dig(:filters, :location)
        format_param =    params.dig(:filters, :format)
        topic_param = params.dig(:filters, :topic)
        licence_param = params.dig(:filters, :licence_code)
        
        solr_client = Search::Solr::Client.initialize

        #treat each word as separate keyword search
        query_param.present? ? query="title:\"#{query_param}\" || notes:\"#{query_param}\"" : query="*:*"

        # http://localhost:8983/solr/ckan/select?debugQuery=true&facet.field=organization&facet.sort=index&facet=true&indent=true&q.op=OR&q=*%3A*&rows=0

        sort_query = "metadata_modified desc" if sort_param == "recent"
        
        filter_query = []
        filter_query << publisher_filter(publisher_param) if publisher_param.present?
        filter_query << format_filter(format_param) if format_param.present?
        filter_query << topic_filter(topic_param) if topic_param.present?
        filter_query << licence_filter(licence_param) if licence_param.present?

        # solr_client.get 'select', :params => { :q => query, :fq => filter_query, :fl => field_list }
# binding.pry
        solr_client.paginate page, 20, 'select', :params => { :q => query, :fq => filter_query, :fl => field_list, :sort => sort_query }


        # solr_client.get 'select', :params => { :q => query, :fq => filter_query, :fl => field_list, :sort => sort_query }

      end
    
      def self.publisher_filter(publisher)
        "organization:#{publisher.parameterize(separator: "-")}"
      end

      def self.format_filter(format)
        "res_format:#{format}"
      end

      def self.topic_filter(topic)
        "extras_theme-primary:\"#{topic}\""
      end

      def self.licence_filter(licence)
        "license_id:#{licence}"
      end

      # def self.by_uuid(uuid)
      # end

      # update fields returned
      def self.field_list
        %w[
          id
          name
          title
          organization
          extras_dcat_publisher_name
          notes
          metadata_modified
          extras_theme-primary
          extras_metadata-date
          res_description
          res_url
          res_format
          validated_data_dict
        ].freeze
      end
      # res_description
          # res_url
          # res_format
          # validated_data_dict

      private_class_method :publisher_filter, :topic_filter, :format_filter, :licence_filter
    end
  end
end