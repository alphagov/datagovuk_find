module Search
  module Solr
    class Client
      ENV['SOLR_URL'] = "http://localhost:8983/solr/ckan"

      def self.initialize
        @client ||= begin
          RSolr.connect :url => ENV['SOLR_URL']
        end
      end
    end
  end
end