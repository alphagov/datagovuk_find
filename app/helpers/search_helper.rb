require "open-uri"

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

  def solr_dataset_publishers_for_select
    Rails.cache.fetch("org_list", expires_in: 24.hours) do
      organisations_list = []

      solr_client = Search::Solr::Client.initialize

      org_facet_list = solr_client.get 'select', :params => { :q => "*:*", :fl => "organization", :rows => 1, :facet => "true", "facet.field" => "organization", "facet.sort" => "index", "facet.limit" => 1500 }

      slugs = org_facet_list["facet_counts"]["facet_fields"]["organization"]

      slugs = slugs.values_at(* slugs.each_index.select {|i| i.even?})

      slugs.each do |slug| # ~1200 solr calls
        response = solr_client.get 'select', :params => { :q => slug, :fl => "validated_data_dict:[json]", :df => "organization", :rows => 1 }

        organisations_list << response["response"]["docs"][0]["validated_data_dict"]["organization"]["title"]
      end

      organisations_list.sort!
    end
  end

  def solr_dataset_topics_for_select
    [
      "Business and economy",
      "Crime and justice",
      "Defence",
      "Digital service performance",
      "Education",
      "Environment",
      "Government",
      "Government reference data",
      "Government spending",
      "Health",
      "Mapping",
      "Society",
      "Towns and cities",
      "Transport",
  ].freeze
  end

  def solr_datafile_formats_for_select
    %w[
        CSV
        GEOJSON
        HTML
        KML
        PDF
        WMS
        XLS
        XML
        ZIP
  ].freeze
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
    buckets.map { |bucket| bucket["key"] }.sort.uniq.reject(&:empty?)
  end

  def search
    query = Search::Query.search(params)
    Dataset.search(query, track_total_hits: true)
  end
end
