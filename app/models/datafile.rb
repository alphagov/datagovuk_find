class Datafile
  DatafileNotFound = Class.new(StandardError)

  attr_reader :name, :url, :start_date,
              :created_at, :updated_at, :format, :size, :uuid

  def initialize(hash)
    @name = hash["name"]
    @url = hash["url"]
    @start_date = hash["start_date"]
    @created_at = hash["created_at"]
    @updated_at = hash["updated_at"]
    @format = hash["format"]&.strip&.delete_prefix(".")&.upcase
    @size = hash["size"]
    @uuid = hash["uuid"]
  end

  def start_year
    return if start_date.blank?

    Time.zone.parse(start_date).year
  end

  def timeseries?
    start_date.present?
  end

  def non_timeseries?
    start_date.blank?
  end

  def html?
    format == "HTML"
  end

  def csv?
    format == "CSV"
  end

  def wms?
    format == "WMS"
  end

  def wfs?
    format == "WFS"
  end

  def preview
    @preview ||= Preview.new(url:, format:)
  end
end
