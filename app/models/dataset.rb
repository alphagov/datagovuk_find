class Dataset
  include ActiveModel::Model
  include Elasticsearch::Model

  attr_accessor :name, :title, :summary, :description,
                :location1, :location2, :location3,
                :licence, :licence_other, :frequency,
                :published_date, :last_updated_at, :created_at,
                :harvested, :uuid, :organisation, :datafiles,
                :inspire_dataset, :json, :notes,
                :_index, :_type, :_id, :_score, :_source,
                :_version

  index_name ENV['ES_INDEX'] || "datasets-#{Rails.env}"

  def self.get_by(name:)
    query = Search::Query.by_name(name)
    response = Search::Request.submit(query)
    result = Search::Response.parse(response).first
    attrs = result.source.merge(_id: result.id)
    Dataset.new(attrs)
  end

  def self.related(id)
    query = Search::Query.related(id)
    response = Search::Request.submit(query)
    results = Search::Response.parse(response)

    results.map do |result|
      attrs = result.source.merge(_id: result.id)
      Dataset.new(attrs)
    end
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
end
