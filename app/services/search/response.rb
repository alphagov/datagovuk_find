module Search
  class Response
    def self.parse(response)
      results = response['hits']['hits']

      results.map do |result|
        Result.new(id: result['_id'], source: result['_source'])
      end
    end
  end
end
