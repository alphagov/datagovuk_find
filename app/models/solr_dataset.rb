class SolrDataset
  include ActiveModel::Model

  DatasetNotFound = Class.new(StandardError)

  attr_reader :id, :name, :title, :summary, :public_updated_at, :topic, :licence_title, :licence_url, :organisation

  def initialize(dataset)
    @id = dataset["id"]
    @name = dataset["name"]
    @title = dataset["title"]
    @summary = dataset["notes"]
    @public_updated_at = dataset["metadata_modified"]
    @topic = dataset["extras_theme-primary"].gsub(/-/, " ").capitalize if dataset["extras_theme-primary"].present?

    dataset_dict = JSON.parse(dataset["validated_data_dict"])
    @licence_title = dataset_dict["license_title"]
    @licence_url = dataset_dict["license_url"]
    @organisation = dataset_dict["organization"]
  end
end
