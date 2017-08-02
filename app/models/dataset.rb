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
       :inspire_dataset, :json,
       :_index, :_type, :_id, :_score, :_source,
       :_version

  class << self
    def from_json(raw_json)
      d = Dataset.new(raw_json.merge(raw_json['_source']))
      d.json = raw_json
      d
    end

    def get(params)
      result = ELASTIC.get(params.merge({index: Dataset.index_name}))
      result.delete 'found' # TODO: don't delete this
      Dataset.from_json(result)
    end
  end

  index_name "datasets-#{Rails.env}"
end
