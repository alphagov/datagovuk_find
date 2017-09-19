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
  include QueryBuilder

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
    def from_json(raw_json)
      d = Dataset.new(raw_json.merge(raw_json['_source']))
      d.json = raw_json
      d
    end

    def get_by(name:)
      query = {
        query: {
          constant_score: {
            filter: {
              term: { name: name }
            }
          }
        }
      }

      result = ELASTIC.search(body: query)
      Dataset.from_json(result['hits']['hits'][0])
    end

    def related(query)
      result = ELASTIC.search body: query

      result['hits']['hits'].map{|hit| Dataset.from_json(hit)}
    end
  end
  index_name ENV['ES_INDEX'] || "datasets-#{Rails.env}"
end
