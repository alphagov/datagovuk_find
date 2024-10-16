class SolrDataset
  include ActiveModel::Model

  DatasetNotFound = Class.new(StandardError)

  attr_reader :id, :name, :title, :summary, :public_updated_at, :topic, :licence_title, :licence_url, :organisation, :datafiles, :contact_email, :contact_name, :foi_name, :foi_email, :foi_web, :docs

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
  end

  def get_organisation(name)
    query = Search::Solr.get_organisation(name)
    query["response"]["docs"].first
  end
end
