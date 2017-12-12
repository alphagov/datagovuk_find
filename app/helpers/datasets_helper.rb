module DatasetsHelper
#TODO fix financial year calculation. 
  FREQUENCIES = {
      'annually' => {years: 1},
      'quarterly' => {months: 4},
      'monthly' => {months: 1},
      'daily' => {days: 1},
      'financial-year' => {years: 1}
  }

  NO_MORE = {
      'never' => 'No future updates',
      'discontinued' => 'Dataset no longer updated',
      'irregular' => 'Not available',
      'default' => 'Not available'
  }

  def unescape(str)
    str = strip_tags(str).html_safe
    str = str.gsub(/&(amp;)+/, '&')
    HTMLEntities.new.decode(str)
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
    "dgu-unavailable" if NO_MORE.include?(freq)
  end

  def dataset_location(dataset)
    locations(dataset).empty? ? NO_MORE['default'] : locations(dataset)
  end

  def expected_location_class_for(dataset)
    "dgu-unavailable" if locations(dataset).empty?
  end

  def name_of(dataset)
    dataset._source['name']
  end

  private

  def datafile_next_updated(dataset)
    freq = dataset.frequency
    last = Time.parse(most_recent_date(dataset.datafiles))

    return last.advance(FREQUENCIES[freq]).strftime("%d %B %Y") if FREQUENCIES.has_key?(freq)
    return NO_MORE[freq] if NO_MORE.has_key?(freq)
    NO_MORE['default']
  end

  def most_recent_date(datafiles)
    datafiles.map(&:most_recent_date).max
  end

  def documents(datafiles)
    datafiles.select do |file|
      documentation?(file.documentation)
    end
  end

  def locations(dataset)
    ['location1', 'location2', 'location3']
        .map {|loc| dataset.send(loc) }
        .join(" ")
        .strip
  end

  def show_more?(datafiles, datafile)
    "js-show-more-datafiles" unless datafiles.take(5).include? datafile
  end
end
