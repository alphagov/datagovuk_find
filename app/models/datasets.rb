class Datasets
  include Elasticsearch::Model

  class << self
    def locations
      query = Search::Query.locations_aggregation
      buckets = search(query)['aggregations']['locations']['buckets']
      map_keys(buckets)
    end

    def publishers
      query = Search::Query.publishers_aggregation
      buckets = search(query)['aggregations']['organisations']['org_titles']['buckets']
      map_keys(buckets)
    end

    private

    def map_keys(buckets)
      buckets.map { |bucket| bucket['key'] }
    end

    def search(query)
      ELASTIC.search body: query
    end
  end
end
