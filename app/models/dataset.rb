class DatasetSearchResponse
  include ActiveModel::Model
  attr_accessor :datasets, :raw
  # This class can be improved by porting over more metadata from the raw response

  def num_results
    self.raw["hits"]["total"]
  end
end


class Dataset
  include ActiveModel::Model
  include Elasticsearch::Model
  attr_accessor :name, :title, :summary, :description,
                :location1, :location2, :location3,
                :licence, :licence_other, :frequency,
                :published_date, :updated_at, :created_at,
                :harvested, :uuid, :organisation, :datafiles,
                :inspire_dataset, :json, :notes,
                :_index, :_type, :_id, :_score, :_source,
                :_version

  class << self
    def from_json(raw_json)
      d = Dataset.new(raw_json.merge(raw_json['_source']))
      d.json = raw_json
      d
    end

    def get(query)
      result = ELASTIC.search body: query
      Dataset.from_json(result['hits']['hits'][0])
    end

    def related(query)
      result = ELASTIC.search body: query

      result['hits']['hits'].map{|hit| Dataset.from_json(hit)}
    end
  end
  index_name ENV.fetch("ES_INDEX", "data_discovery")
end
