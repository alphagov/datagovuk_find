class Datafile
  DatafileNotFound = Class.new(StandardError)

  attr_reader :name, :url, :start_date, :end_date,
              :created_at, :updated_at, :format, :size, :uuid

  def initialize(hash)
    @name = hash["name"]
    @url = hash["url"]
    @start_date = hash["start_date"]
    @end_date = hash["end_date"]
    @created_at = hash["created_at"]
    @updated_at = hash["updated_at"]
    @format = hash["format"]
    @size = hash["size"]
    @uuid = hash["uuid"]
  end

  def start_year
    return if start_date.blank?
    Time.parse(start_date).year
  end

  def most_recent_date
    return updated_at if end_date.blank?
    end_date > updated_at ? end_date : updated_at
  end

  def timeseries?
    start_date.present?
  end

  def non_timeseries?
    start_date.blank?
  end

  def html?
    format&.upcase == 'HTML'
  end

  def csv?
    format&.upcase == 'CSV'
  end

  def wms?
    format&.upcase == 'WMS'
  end

  def wfs?
    format&.upcase == 'WFS'
  end

  def preview
    @preview ||= Preview.new(url: url, format: format)
  end
end
