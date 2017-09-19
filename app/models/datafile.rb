class Datafile
  attr_reader :name, :url, :start_date, :end_date,
              :updated_at, :format, :size, :documentation

  def initialize(attrs)
    @name = attrs["name"]
    @url = attrs["url"]
    @start_date = attrs["start_date"]
    @end_date = attrs["end_date"]
    @updated_at = attrs["updated_at"]
    @format =  attrs["format"]
    @size =  attrs["size"]
    @documentation = attrs["documentation"]
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
end
