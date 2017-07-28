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
    last = @dataset["updated_at"]
    freq = @dataset["frequency"]

    if FREQUENCIES.has_key?(freq)
      "<dd>#{format(last.advance(FREQUENCIES[freq]))}</dd>".html_safe
    elsif NO_MORE.has_key?(freq)
      "<dd class='unavailable'> #{NO_MORE[freq]}</dd>".html_safe
    else
      "<dd class='unavailable'> Not available </dd>".html_safe
    end
  end


end
