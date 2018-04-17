class Dataset
  include ActiveModel::Model
  include Elasticsearch::Model

  DatasetNotFound = Class.new(StandardError)

  attr_accessor :name, :legacy_name, :title, :summary, :description,
                :location1, :location2, :location3,
                :foi_name, :foi_email, :foi_phone, :foi_web,
                :contact_name, :contact_email, :contact_phone,
                :licence, :licence_other, :frequency,
                :published_date, :last_updated_at, :created_at,
                :harvested, :uuid, :short_id, :topic,
                :inspire_dataset, :json, :notes,
                :_index, :_type, :_id, :_score, :_source,
                :_version

  attr_reader :organisation

  index_name ENV['ES_INDEX'] || "datasets-#{Rails.env}"

  def self.get_by_query(query:)
    Dataset
      .search(query)
      .map { |result| result._source.to_hash.merge(_id: result._id) }
      .reject { |attributes| attributes['title'].blank? }
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

  def self.locations
    query = Search::Query.locations_aggregation
    buckets = Dataset.search(query).aggregations['locations']['buckets']
    map_keys(buckets)
  end

  def self.publishers
    query = Search::Query.publishers_aggregation
    buckets = Dataset.search(query).aggregations['organisations']['org_titles']['buckets']
    map_keys(buckets)
  end

  def self.topics
    query = Search::Query.dataset_topics_aggregation
    buckets = Dataset.search(query).aggregations['topics']['topic_titles']['buckets']
    map_keys(buckets)
  end

  def self.datafile_formats
    query = Search::Query.datafile_formats_aggregation
    buckets = Dataset.search(query).aggregations['datafiles']['datafile_formats']['buckets']
    map_keys(buckets)
  end

  def self.datafiles
    query = Search::Query.datafiles_aggregation
    Dataset.search(query).aggregations['datafiles']
  end

  def docs
    Array(@docs)
  end

  def docs=(docs)
    @docs = docs.map { |file| Doc.new(file) }
  end

  def datafiles
    Array(@datafiles)
  end

  def datafiles=(datafiles)
    @datafiles = datafiles.map { |file| Datafile.new(file)}
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

  def self.map_keys(buckets)
    buckets.map { |bucket| bucket['key'] }
  end

  def organisation=(organisation)
    @organisation = Organisation.new(organisation)
  end

  def editable?
    harvested == false
  end

  private_class_method :map_keys
end
