class Dataset
  include ActiveModel::Model
  include Elasticsearch::Model

  DatasetNotFound = Class.new(StandardError)

  attr_reader :name, :legacy_name, :title, :summary, :description, :foi_name,
              :organisation, :id, :uuid, :datafiles, :licence, :licence_other,
              :location1, :location2, :location3, :public_updated_at, :topic,
              :licence_custom, :docs, :contact_email, :foi_email, :foi_web,
              :notes, :inspire_dataset, :harvested, :contact_name, :released

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
    @notes = hash["notes"]
    @inspire_dataset = hash["inspire_dataset"]
    @harvested = hash["harvested"]
    @organisation = Organisation.new(hash["organisation"])
    @datafiles = hash["datafiles"].map { |file| Datafile.new(file) }
    @docs = hash["docs"].map { |file| Doc.new(file) }
  end

  def self.get_by_query(query:)
    Dataset
      .search(query)
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

  def editable?
    harvested == false
  end
end
