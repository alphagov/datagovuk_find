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
                :_version

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
    @licence_title || case licence_code
                      when 'cc-by'
                        'Creative Commons Attribution'
                      when 'cc-by-sa'
                        'Creative Commons Attribution Share-Alike'
                      when 'cc-nc'
                        'Creative Commons Non-Commercial (Any)'
                      when 'cc-zero'
                        'Creative Commons CCZero'
                      when 'notspecified'
                        'License Not Specified'
                      when 'odc-by'
                        'Open Data Commons Attribution License'
                      when 'odc-odbl'
                        'Open Data Commons Open Database License (ODbL)'
                      when 'odc-pddl'
                        'Open Data Commons Public Domain Dedication and License (PDDL)'
                      when 'other'
                        'Other'
                      when 'other-closed'
                        'Other (Not Open)'
                      when 'other-nc'
                        'Other (Non-Commercial)'
                      when 'other-open'
                        'Other (Open)'
                      when 'other-pd'
                        'Other (Public Domain)'
                      when 'uk-ogl'
                        'Open Government Licence'
                      end
  end

  def licence_url
    @licence_url || case licence_code
                    when 'cc-by'
                      'http://www.opendefinition.org/licenses/cc-by'
                    when 'cc-by-sa'
                      'http://www.opendefinition.org/licenses/cc-by-sa'
                    when 'cc-nc'
                      'http://creativecommons.org/licenses/by-nc/2.0/'
                    when 'cc-zero'
                      'http://www.opendefinition.org/licenses/cc-zero'
                    when 'odc-by'
                      'http://www.opendefinition.org/licenses/odc-by'
                    when 'odc-odbl'
                      'http://www.opendefinition.org/licenses/odc-odbl'
                    when 'odc-pddl'
                      'http://www.opendefinition.org/licenses/odc-pddl'
                    when 'uk-ogl'
                      'http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/'
                    end
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
