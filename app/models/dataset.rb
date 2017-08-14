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

    def get(name)
      dataset_by_name_query = {
        query: {
          constant_score: {
            filter: {
              term: {
                name: name
              }
            }
          }
        }
      }

      result = ELASTIC.search body: dataset_by_name_query
      Dataset.from_json(result['hits']['hits'][0])
    end

    def related_to(id)
      related_datasets_query = {
        size: 4,
        query: {
          more_like_this: {
            fields: %w(title summary description organisation^2 location*^2),
            like: {
              _index: "datasets-#{Rails.env}",
              _type: "dataset",
              _id: id
            },
            min_term_freq: 1,
            min_doc_freq: 1
          }
        }
      }

      result = ELASTIC.search body: related_datasets_query

      result['hits']['hits'].map{|hit| Dataset.from_json(hit)}
    end

  end

  index_name "datasets-#{Rails.env}"
end
