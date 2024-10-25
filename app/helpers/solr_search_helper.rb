module SolrSearchHelper
  def selected_publisher
    params.dig(:filters, :publisher)
  end

  def selected_topic
    params.dig(:filters, :topic)
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
end
