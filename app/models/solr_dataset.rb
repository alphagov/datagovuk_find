class SolrDataset
  include ActiveModel::Model

  attr_reader :title, :summary, :public_updated_at, :organisation

  def initialize(dataset)
    @title = dataset["title"]
    @summary = dataset["notes"]
    @public_updated_at = dataset["metadata_modified"]
    dataset_dict = JSON.parse(dataset["validated_data_dict"])
    @organisation = dataset_dict["organization"]["title"]
  end
end
