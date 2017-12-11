class Dataset
  include ActiveModel::Model
  include Elasticsearch::Model

  attr_accessor :name, :title, :summary, :description,
                :location1, :location2, :location3,
                :licence, :licence_other, :frequency,
                :published_date, :last_updated_at, :created_at,
                :harvested, :uuid, :organisation, :datafiles,
                :inspire_dataset, :json, :notes,
                :contact_name, :contact_email, :contact_phone,
                :foi_name, :foi_email, :foi_phone, :foi_web,
                :_index, :_type, :_id, :_score, :_source,
                :_version

  index_name ENV['ES_INDEX'] || "datasets-#{Rails.env}"

  def self.get_by(uuid:)
    query = Search::Query.by_uuid(uuid)
    result = Dataset.search(query).results.first
    attrs = result._source.to_hash.merge(_id: result._id)
    raise 'Metadata missing' if attrs["title"].blank?
    Dataset.new(attrs)
  end

  def self.related(id)
    query = Search::Query.related(id)

    Dataset.search(query).results.map do |result|
      attrs = result._source.to_hash.merge(_id: result._id)
      Dataset.new(attrs)
    end
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

  def datafiles
    @datafiles.map { |file| Datafile.new(file) }
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

  private_class_method :map_keys
end
