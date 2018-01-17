module SearchHelper

  def display_sort(sort)
    sort == 'best' ? "Best Match" : "Most Recent"
  end

  def format(timestamp)
    Time.parse(timestamp).strftime("%d %B %Y")
  end

  def datafile_formats_for_select
    Dataset.datafile_formats.unshift("").uniq
  end

  def selected_format
    params.dig(:filters, :format)
  end

  def selected_filters
    return [] if no_filters_selected?
    params[:filters].except(:publisher).values.reject(&:blank?)
  end

  private

  def no_filters_selected?
    params[:filters].nil? || params[:filters].values.reject(&:blank?).empty?
  end
end
