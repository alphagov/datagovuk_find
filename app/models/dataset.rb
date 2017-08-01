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

  index_name "datasets-#{Rails.env}"
end
