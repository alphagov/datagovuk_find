module SolrSearchHelper
  def selected_publisher
    params.dig(:filters, :publisher)
  end

  def selected_topic
    params.dig(:filters, :topic)
  end

  def selected_format
    params.dig(:filters, :format)
  end

  def dataset_topics_for_select
    if params.fetch("q", "").empty?
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
    else
      # the topics returned are being split by whitespace

      topics = @query["facet_counts"]["facet_fields"]["extras_theme-primary"]

      topics = topics.values_at(* topics.each_index.select(&:even?))

      # results_topics = []
      # slugs.each do |topic|
      #   results_topics << Search::Solr.get_topic(topic)["response"]["docs"].first["title"]
      # end
      topics
    end
  end

  def datafile_formats_for_select
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
end
