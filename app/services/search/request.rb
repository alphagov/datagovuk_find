module Search
  class Request
    def self.submit(query)
      ELASTIC.search(body: query)
    end
  end
end
