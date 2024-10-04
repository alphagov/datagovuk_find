class SolrDataset
  include ActiveModel::Model

  DatasetNotFound = Class.new(StandardError)

  attr_reader :id, :name, :title, :public_updated_at, :licence_title, :organisation

  def initialize(dataset)
    @id = dataset["id"]
    @name = dataset["name"]
    @title = dataset["title"]
    @public_updated_at = dataset["metadata_modified"]

    dataset_dict = JSON.parse(dataset["validated_data_dict"])
    @licence_title = dataset_dict["license_title"]
    @organisation = dataset_dict["organization"]
  end
end
