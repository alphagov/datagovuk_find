class Dataset
  include ActiveModel::Model
  include Elasticsearch::Model

  DatasetNotFound = Class.new(StandardError)

  attr_accessor :name, :legacy_name, :title, :summary, :description,
                :location1, :location2, :location3,
                :foi_name, :foi_email, :foi_phone, :foi_web,
                :contact_name, :contact_email, :contact_phone,
                :licence_custom, :licence, :licence_other, :frequency,
                :published_date, :last_updated_at, :created_at,
                :harvested, :uuid, :short_id, :topic,
                :inspire_dataset, :json, :notes,
                :_index, :_type, :_id, :_score, :_source,
                :_version, :public_updated_at

  attr_writer :licence_code, :licence_title, :licence_url
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

  def self.publishers
    query = { aggs: Search::Query.publishers_aggregation }
    buckets = Dataset.search(query).aggregations['organisations']['org_titles']['buckets']
    buckets.map { |bucket| bucket['key'] }.sort.uniq.reject(&:empty?)
  end

  def self.datafiles
    query = { aggs: Search::Query.datafiles_aggregation }
    Dataset.search(query).aggregations['datafiles']
  end

  def released?
    (docs.count + datafiles.count).positive?
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
    @datafiles = datafiles.map { |file| Datafile.new(file) }
  end

  def licence?
    licence_code.present?
  end

  def licence_code
    @licence_code || case licence
                     when 'other'
                       licence_other
                     when 'no-licence'
                       if licence_custom.present?
                         'other'
                       end
                     else
                       licence
                     end
  end

  def licence_title
    @licence_title || I18n.t("datasets.licence_title.#{licence_code}")
  end

  def licence_url
    @licence_url || I18n.t("datasets.licence_url.#{licence_code}")
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

  def organisation=(organisation)
    @organisation = Organisation.new(organisation)
  end

  def editable?
    harvested == false
  end
end
