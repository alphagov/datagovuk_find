class SolrDataset
  include ActiveModel::Model

  attr_reader :uuid, :name, :title, :summary, :public_updated_at, :topic, :licence_title, :licence_url, :organisation, :datafiles, :contact_email, :contact_name, :foi_name, :foi_email, :foi_web, :docs, :licence_custom, :inspire_dataset, :harvested, :licence_code

  ORGANOGRAM_SCHEMA_IDS = [
    "538b857a-64ba-490e-8440-0e32094a28a7", # Local authority
    "d3c0b23f-6979-45e4-88ed-d2ab59b005d0", # Departmental
  ].freeze

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
    @schema_id = dataset_dict["schema-vocabulary"]

    @contact_email = dataset_dict["contact-email"]
    @contact_name = dataset_dict["contact-name"]
    @foi_name = dataset_dict["foi-name"]
    @foi_email = dataset_dict["foi-email"]
    @foi_web = dataset_dict["foi-web"]

    @inspire_dataset = additional_information(dataset_dict["extras"]) if dataset_dict["extras"].present?
    @harvested = @inspire_dataset.present? ? true : false
  end

  def self.get_by_uuid(uuid:)
    get_by_query(query: "id:#{uuid}")
  end

  def self.get_by_legacy_name(legacy_name:)
    get_by_query(query: "name:#{legacy_name}")
  end

  def editable?
    harvested == false
  end

  def organogram?
    return false unless @schema_id

    schema_id = @schema_id.gsub(/\["|"\]/, "")
    ORGANOGRAM_SCHEMA_IDS.include?(schema_id)
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

  def self.get_by_query(query:)
    solr_client = Search::Solr.client

    response = begin
      solr_client.get "select", params: {
        q: query,
        fq: "state:active",
        fl: Search::Solr.field_list,
      }
    rescue RSolr::Error::Http => e
      if e.response[:status] == 404
        raise NotFound
      else
        raise e
      end
    end

    dataset_attr = response["response"]["docs"].first
    raise NotFound if dataset_attr.nil?

    SolrDataset.new(dataset_attr)
  end

  class NotFound < StandardError; end
end
