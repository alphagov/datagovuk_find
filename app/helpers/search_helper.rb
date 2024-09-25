module SearchHelper
  def display_sort(sort)
    sort == "best" ? "Best Match" : "Most Recent"
  end

  def datafile_formats_for_select
    buckets = search.aggregations["datafiles"]["datafile_formats"]["buckets"]
    map_keys(buckets).map(&:upcase)
  end

  def dataset_topics_for_select
    buckets = search.aggregations["topics"]["topic_titles"]["buckets"]
    map_keys(buckets)
  end

  def dataset_publishers_for_select
    buckets = search.aggregations["organisations"]["org_titles"]["buckets"]
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

  def search_results_metadata(dataset)
    items = []

    items << {
      field: t('search.search.meta_data_box.availability'),
      value: t('search.search.meta_data_box.not_released'),
    } unless dataset.released?

    items << {
      field: t('search.search.meta_data_box.published_by'),
      value: dataset.organisation['title'],
    }

    if dataset.public_updated_at.present?
      updated_value = format_timestamp(dataset.public_updated_at)
    else
      updated_value = t('search.search.meta_data_box.not_applicable')
    end

    items << {
      field: t('search.search.meta_data_box.last_updated'),
      value: updated_value
    }

    items
  end

private

  def no_filters_selected?
    params[:filters].nil? || params[:filters].values.reject(&:blank?).empty?
  end

  def map_keys(buckets)
    buckets.map { |bucket| bucket["key"] }.sort.uniq.reject(&:empty?)
  end

  def search
    query = Search::Query.search(params)
    Dataset.search(query, track_total_hits: true)
  end
end
