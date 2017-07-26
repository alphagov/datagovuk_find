class DatasetSearchResponse
  include ActiveModel::Model
  attr_accessor :datasets, :raw
  # This class can be improved by porting over more metadata from the raw response
end

class Dataset
  include ActiveModel::Model
  attr_accessor :name, :title, :summary, :description,
       :location1, :location2, :location3,
       :licence, :licence_other, :frequency,
       :published_date, :updated_at, :created_at,
       :harvested, :uuid, :organisation, :datafiles,
       :inspire_dataset, :json,
       :_index, :_type, :_id, :_score, :_source,
       :_version
  # TODO: subclass for datafiles

  class << self
    def from_json(raw_json)
      d = Dataset.new(raw_json)
      d.json = raw_json
      d
    end

    def index
      "datasets-#{Rails.env}"
    end

    def search(params)
      results = ELASTIC.search(params.merge({index: Dataset.index}))
      hits = results['hits']['hits']

      datasets = hits.map do |hit|
        Dataset.from_json(hit)
      end

      DatasetSearchResponse.new(datasets: datasets, raw: results)
    end

    def get(params)
      result = ELASTIC.get(params.merge({index: Dataset.index}))
      result.delete 'found' # TODO: don't delete this
      Dataset.from_json(result)
    end

    def _query(method, params)
      ELASTIC.send(method, params.merge({index: Dataset.index}))
    end
  end
end
