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
                :published_date, :last_updated_at, :created_at,
                :harvested, :uuid, :organisation, :datafiles,
                :inspire_dataset, :json, :notes,
                :_index, :_type, :_id, :_score, :_source,
                :_version

  def datafiles
    @datafiles.map { |file| Datafile.new(file) }
  end

  def timeseries_datafiles
    datafiles.select(&:timeseries?)
  end

  def non_timeseries_datafiles
    datafiles.select(&:non_timeseries?)
  end

  class << self
    def get_by(id:)
      response = ELASTIC.get(index: index_name, id: id)
      result = response["_source"]
      Dataset.new(result.merge(_id: response["_id"]))
    end

    def related(query)
      response = ELASTIC.search(body: query)
      results = response["hits"]["hits"]

      results.map do |result|
        id = result["_id"]
        result = result["_source"]
        Dataset.new(result.merge(_id: id))
      end
    end
  end
  index_name ENV['ES_INDEX'] || "datasets-#{Rails.env}"
end
