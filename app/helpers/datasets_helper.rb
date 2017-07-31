module DatasetsHelper

  FREQUENCIES = {
    'annual' => { years: 1 },
    'quarterly' => { months: 4 },
    'monthly' => { months: 1 },
    'daily' => { days: 1 }
  }

  NO_MORE = {
    'discontinued' => 'Dataset no longer updated',
    'never' => 'No future updates',
    'one off' => 'No future updates'
  }

  def documents
    docs = []
    @dataset['datafiles'].each do |file|
      if documentation?(file['documentation'])
        docs << file['documentation']
      end
    end
    docs
  end

  def format(timestamp)
    Time.parse(timestamp).strftime("%d %B %Y")
  end

  def no_documents?
    d = documents
    d.count == 0
  end

  def documentation?(key)
    key != nil && key != ""
  end

  def expected_update
    if @dataset["datafiles"].any?
      datafile_next_updated(@dataset["frequency"])
    else
      # TODO placeholder error message - should we just hide field if there are no datafiles?
      "<dd class='unavailable'> This dataset has no data yet </dd>".html_safe
    end
  end

  def datafile_next_updated(freq)
    last = Time.parse(most_recent_date)

    if FREQUENCIES.has_key?(freq)
      "<dd>#{ last.advance(FREQUENCIES[freq]).strftime("%d %B %Y") }</dd>".html_safe
    elsif NO_MORE.has_key?(freq)
      "<dd class='unavailable'> #{NO_MORE[freq]}</dd>".html_safe
    else
      "<dd class='unavailable'> Not available </dd>".html_safe
    end
  end

  def no_end_date_on_datafiles?
    @dataset["datafiles"].reject do |file|
      file["end_date"].nil?
    end.map{ |file| file }.empty?
  end

  def most_recent_date
    date_field = no_end_date_on_datafiles? ? "updated_at" : "end_date"
    most_recent_datafile =
      @dataset["datafiles"].sort_by{ |file| file[date_field].to_s }.reverse[0]
    most_recent_datafile[date_field]
  end

  def dataset_location
    locations =
      ["location1", "location2", "location3"].map{ |loc| @dataset[loc] }
    if locations.join(" ").strip.empty?
        "<dd class='unavailable'>Not applicable</dd>".html_safe
    else
        "<dd>#{locations.join(" ").strip}</dd>".html_safe
    end
  end
end
