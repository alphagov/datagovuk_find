class Dataset
  include ActiveModel::Model
  include Elasticsearch::Model

  DatasetNotFound = Class.new(StandardError)

  attr_reader :name, :legacy_name, :title, :summary, :description, :foi_name,
              :organisation, :id, :uuid, :datafiles, :location1, :location2,
              :location3, :public_updated_at, :topic, :licence_custom, :docs,
              :contact_email, :foi_email, :foi_web, :inspire_dataset, :harvested,
              :contact_name, :released, :licence_title, :licence_url, :licence_code

  ORGANOGRAM_SCHEMA_IDS = [
    "538b857a-64ba-490e-8440-0e32094a28a7", # Local authority
    "d3c0b23f-6979-45e4-88ed-d2ab59b005d0", # Departmental
  ].freeze

  index_name ENV['ES_INDEX'] || "datasets-#{Rails.env}"

  def initialize(hash)
    @name = hash["name"]
    @legacy_name = hash["legacy_name"]
    @title = hash["title"]
    @summary = hash["summary"]
    @description = hash["description"]
    @id = hash["_id"]
    @uuid = hash["uuid"]
    @location1 = hash["location1"]
    @location2 = hash["location2"]
    @location3 = hash["location3"]
    @released = hash["released"]
    @licence = hash["licence"]
    @licence_other = hash["licence_other"]
    @licence_custom = hash["licence_custom"]
    @licence_title = hash["licence_title"]
    @licence_url = hash["licence_url"]
    @licence_code = hash["licence_code"]
    @public_updated_at = hash["public_updated_at"]
    @topic = hash["topic"]
    @contact_email = hash["contact_email"]
    @contact_name = hash["contact_name"]
    @foi_name = hash["foi_name"]
    @foi_email = hash["foi_email"]
    @foi_web = hash["foi_web"]
    @inspire_dataset = hash["inspire_dataset"]
    @harvested = hash["harvested"]
    @organisation = Organisation.new(hash["organisation"])
    @datafiles = hash["datafiles"].map { |file| Datafile.new(file) }
    @docs = hash["docs"].map { |file| Doc.new(file) }
    @schema_id = hash["schema_id"]
  end

  def self.get_by_query(query:)
    Dataset
      .search(query).to_a
      .map { |result| result._source.to_hash.merge(_id: result._id) }
      .reject { |attributes| attributes['title'].blank? }
      .map(&:stringify_keys)
      .map(&Dataset.method(:new))
  end

  def self.get_by_uuid(uuid:)
    get_by_query(query: Search::Query.by_uuid(uuid))
      .first || raise(DatasetNotFound)
  end

  def self.get_by_legacy_name(legacy_name:)
    get_by_query(query: Search::Query.by_legacy_name(legacy_name))
      .first || raise(DatasetNotFound)
  end

  def self.related(id)
    get_by_query(query: Search::Query.related(id))
  end

  def self.publishers
    query = { aggs: Search::Query.publishers_aggregation }
    buckets = Dataset.search(query).aggregations['organisations']['org_titles']['buckets']
    buckets.map { |bucket| bucket['key'] }.sort.uniq.reject(&:empty?)
  end

  def self.datafiles
    query = { aggs: Search::Query.datafiles_aggregation }
    Dataset.search(query).aggregations['datafiles']
  end

  def links
    docs + datafiles
  end

  def timeseries_datafiles
    datafiles.select(&:timeseries?)
  end

  def non_timeseries_datafiles
    datafiles.select(&:non_timeseries?)
  end

  def editable?
    harvested == false
  end

  def organogram?
    schema_id = @schema_id.gsub(/\["|"\]/, '')
    ORGANOGRAM_SCHEMA_IDS.include?(schema_id)
  end
end
