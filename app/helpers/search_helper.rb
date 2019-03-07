module SearchHelper
  def display_sort(sort)
    sort == 'best' ? 'Best Match' : 'Most Recent'
  end

  def datafile_formats_for_select
    buckets = search.aggregations['datafiles']['datafile_formats']['buckets']
    map_keys(buckets).map(&:upcase)
  end

  def dataset_topics_for_select
    buckets = search.aggregations['topics']['topic_titles']['buckets']
    map_keys(buckets)
  end

  def dataset_publishers_for_select
    buckets = search.aggregations['organisations']['org_titles']['buckets']
    map_keys(buckets)
  end

  def selected_publisher
    params.dig(:filters, :publisher)
  end

  def selected_topic
    params.dig(:filters, :topic)
  end

  def selected_format
    params.dig(:filters, :format)
  end

  def selected_filters
    return [] if no_filters_selected?

    params[:filters].except(:publisher).values.reject(&:blank?)
  end

  def search_term
    params[:q].presence || selected_topic.presence
  end

private

  def no_filters_selected?
    params[:filters].nil? || params[:filters].values.reject(&:blank?).empty?
  end

  def map_keys(buckets)
    buckets.map { |bucket| bucket['key'] }.sort.uniq.reject(&:empty?)
  end

  def search
    query = Search::Query.search(params)
    Dataset.search(query)
  end
end
