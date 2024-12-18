class SolrDataset
  include ActiveModel::Model

  DatasetNotFound = Class.new(StandardError)

  attr_reader :uuid, :name, :title, :summary, :public_updated_at, :topic, :licence_title, :licence_url, :organisation, :datafiles, :contact_email, :contact_name, :foi_name, :foi_email, :foi_web, :docs, :licence_custom, :inspire_dataset, :harvested, :licence_code

  def initialize(dataset)
    @uuid = dataset["id"]
    @name = dataset["name"]
    @title = dataset["title"]
    @summary = dataset["notes"]
    @public_updated_at = dataset["metadata_modified"]
    @topic = dataset["extras_theme-primary"].gsub(/-/, " ").capitalize if dataset["extras_theme-primary"].present?

    dataset_dict = JSON.parse(dataset["validated_data_dict"])
    @licence_title = dataset_dict["license_title"]
    @licence_url = dataset_dict["license_url"]
    @licence_code = dataset_dict["license_id"]
    @licence_custom = dataset["extras_licence"].gsub(/"|\[|\]/, "") if dataset["extras_licence"].present?

    @organisation = Organisation.new(get_organisation(dataset_dict["organization"]["name"]))

    @datafiles = []
    @docs = []
    dataset_dict["resources"].each do |datafile|
      datafile["resource-type"] == "supporting-document" ? @docs << datafile : @datafiles << SolrDatafile.new(datafile, dataset["metadata_created"])
    end

    @contact_email = dataset_dict["contact-email"]
    @contact_name = dataset_dict["contact-name"]
    @foi_name = dataset_dict["foi-name"]
    @foi_email = dataset_dict["foi-email"]
    @foi_web = dataset_dict["foi-web"]

    @inspire_dataset = additional_information(dataset_dict["extras"]) if dataset_dict["extras"].present?
    @harvested = @inspire_dataset.present? ? true : false
  end

  def editable?
    harvested == false
  end

  def additional_information(data)
    additional_info = {}
    data.each do |item|
      additional_info.store(item["key"], item["value"])
    end

    additional_info = additional_info&.slice(
      "licence",
      "metadata-date",
      "access_constraints",
      "guid",
      "bbox-east-long",
      "bbox-west-long",
      "bbox-north-lat",
      "bbox-south-lat",
      "spatial-reference-system",
      "dataset-reference-date",
      "frequency-of-update",
      "responsible-party",
      "resource-type",
      "metadata-language",
      "harvest_object_id",
    )
    additional_info.empty? ? nil : additional_info
  end

  def get_organisation(name)
    query = Search::Solr.get_organisation(name)
    query["response"]["docs"].first
  end
end
