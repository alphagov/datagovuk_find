class Dataset
  include Elasticsearch::Persistence::Model
  index_name "data_discovery"

  attribute :title, String
end
