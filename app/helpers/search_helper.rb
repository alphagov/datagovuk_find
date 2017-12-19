module SearchHelper

  def display_sort(sort)
    sort == 'best' ? "Best Match" : "Most Recent"
  end

  def format(timestamp)
    Time.parse(timestamp).strftime("%d %B %Y")
  end

  def datafile_formats
    Dataset.datafile_formats
  end

  def selected_format
    params[:format]
  end
end
