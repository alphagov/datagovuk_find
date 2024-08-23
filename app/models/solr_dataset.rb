class SolrDataset
  include ActiveModel::Model

  DatasetNotFound = Class.new(StandardError)

  attr_reader :name, :legacy_name, :title, :summary, :description, :foi_name,
              :organisation, :id, :uuid, :datafiles, :public_updated_at, :topic, :licence_custom, :docs,
              :contact_email, :foi_email, :foi_web, :inspire_dataset, :harvested,
              :contact_name, :released, :licence_title, :licence_url, :licence_code

  ORGANOGRAM_SCHEMA_IDS = [
    "538b857a-64ba-490e-8440-0e32094a28a7", # Local authority
    "d3c0b23f-6979-45e4-88ed-d2ab59b005d0", # Departmental
  ].freeze


  def initialize(dataset)
    @name = dataset["name"]
    @legacy_name = dataset["legacy_name"]
    @title = dataset["title"]
    @summary = dataset["notes"]
    @description = dataset["description"]
    @id = dataset["id"]

    dataset_dict = JSON.parse(dataset["validated_data_dict"])
    @licence_title = dataset_dict["license_title"]
    @licence_url = dataset_dict["license_url"]
    @licence_code = dataset_dict["license_code"]
    @public_updated_at = dataset["metadata_modified"]
    @topic = dataset["extras_theme-primary"].gsub(/-/, " ").capitalize if dataset["extras_theme-primary"].present?
    @contact_email = dataset_dict["contact-email"]
    @contact_name = dataset_dict["contact-name"]
    @foi_name = dataset_dict["foi-name"]
    @foi_email = dataset_dict["foi-email"]
    @foi_web = dataset_dict["foi-web"]
    @inspire_dataset = additional_information(dataset_dict["extras"]) if dataset_dict["extras"].present?
    @licence_custom = @inspire_dataset["licence"] if @inspire_dataset.present?
    @harvested = @inspire_dataset["import_source"] if @inspire_dataset.present?
    @organisation = Organisation.new(dataset_dict["organization"])

    @datafiles = []
    @docs = []
    dataset_dict["resources"].each do |datafile|
      datafile["resource-type"] == "supporting-document" ? @docs << datafile : @datafiles << SolrDatafile.new(datafile)
    end
    @released = @datafiles.present?
    
    @schema_id = dataset_dict["schema-vocabulary"]
  end

  def self.get_by_query(response)
    SolrDataset.new(response.first)
  end

  def self.get_by_uuid(uuid:)
    solr_client = Search::Solr::Client.initialize

    response = solr_client.get 'select', :params => { :q => "*:*", :fq => "id:#{uuid}", :fl => fields}

    get_by_query(response["response"]["docs"]) || raise(DatasetNotFound)
  end

  # def self.get_by_legacy_name(legacy_name:)
  #   get_by_query(query: Search::Query.by_legacy_name(legacy_name))
  #     .first || raise(DatasetNotFound)
  # end

  # def self.related(id)
  #   get_by_query(query: Search::Query.related(id))
  # end

  # def self.publishers
  #   query = { aggs: Search::Query.publishers_aggregation }
  #   buckets = Dataset.search(query).aggregations["organisations"]["org_titles"]["buckets"]
  #   buckets.map { |bucket| bucket["key"] }.sort.uniq.reject(&:empty?)
  # end

  # def self.datafiles
  #   query = { aggs: Search::Query.datafiles_aggregation }
  #   Dataset.search(query).aggregations["datafiles"]
  # end

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

  # def timeseries_datafiles
  #   datafiles.select(&:timeseries?)
  # end

  # def non_timeseries_datafiles
  #   datafiles.select(&:non_timeseries?)
  # end

  def editable?
    true if harvested.nil? || !harvested == "harvest"
  end

  def organogram?
    return false unless @schema_id

    schema_id = @schema_id.gsub(/\["|"\]/, "")
    ORGANOGRAM_SCHEMA_IDS.include?(schema_id)
  end

  def self.fields
    %w[
      id
      name
      title
      notes
      description
      organization
      metadata_modified
      extras_theme-primary # topic
      extras_metadata-date
      validated_data_dict
    ].freeze
  end
end
