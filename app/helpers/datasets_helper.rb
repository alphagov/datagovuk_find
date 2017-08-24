module DatasetsHelper

  FREQUENCIES = {
      'annual' => {years: 1},
      'quarterly' => {months: 4},
      'monthly' => {months: 1},
      'daily' => {days: 1}
  }

  NO_MORE = {
      'discontinued' => 'Dataset no longer updated',
      'never' => 'No future updates',
      'one off' => 'No future updates',
      'default' => 'Not available'
  }

  def unescape(str)
    str = strip_tags(str).html_safe
    str = str.gsub(/&(amp;)+/, '&')
    str = HTMLEntities.new.decode(str)
  end

  def format(timestamp)
    Time.parse(timestamp).strftime("%d %B %Y")
  end

  def no_documents?(datafiles)
    documents(datafiles).count == 0
  end

  def documentation?(key)
    key != nil && key != ""
  end

  def expected_update(dataset)
    dataset.frequency.nil? ?
        NO_MORE['default'] :
        datafile_next_updated(dataset)
  end

  def expected_update_class_for(freq)
    NO_MORE.include?(freq)
    "unavailable"
  end

  def dataset_location(dataset)
    locations(dataset).empty? ? NO_MORE['default'] : locations(dataset)
  end

  def expected_location_class_for(dataset)
    "unavailable" if locations(dataset).empty?
  end

  def timeseries_data?(datafiles)
    start_dates = datafiles.map do |file|
      Time.parse(file['start_date']).year if file['start_date'].present?
    end

    start_dates.uniq.length > 1
  end

  def group_by_year(datasets)
    datasets_with_year = datasets.map do |dataset|
      dataset['start_year'] =
          dataset['start_date'] ? Time.parse(dataset['start_date']).year.to_s : ''
      dataset
    end
    Hash[datasets_with_year.group_by {|dataset| dataset['start_year']}.sort.reverse]
  end

  def format_button(datafile)
    if datafile["format"].blank?
      "link"
    else
      datafile["format"] == 'HTML' ? 'view' : 'download'
    end
  end

  private

  def datafile_next_updated(dataset)
    freq = dataset.frequency
    last = most_recent_date(dataset.datafiles)

    return last.advance(FREQUENCIES[freq]).strftime("%d %B %Y") if FREQUENCIES.has_key?(freq)
    return NO_MORE[freq] if NO_MORE.has_key?(freq)
    NO_MORE['default']
  end

  def no_end_date_on_datafiles?(datafiles)
    datafiles.reject do |file|
      file["end_date"].nil?
    end.map {|file| file}.empty?
  end

  def most_recent_date(datafiles)
    date_field = no_end_date_on_datafiles?(datafiles) ? "updated_at" : "end_date"
    most_recent_datafile =
        datafiles.sort_by {|file| file[date_field].to_s}.reverse[0]
    Time.parse(most_recent_datafile[date_field])
  end

  def documents(datafiles)
    datafiles.select do |file|
      documentation?(file['documentation'])
    end
  end

  def locations(dataset)
    ['location1', 'location2', 'location3']
        .map {|loc| dataset.send(loc) }
        .join(" ")
        .strip
  end

end
