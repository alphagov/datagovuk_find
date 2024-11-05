class SearchPresenter
  attr_reader :search_response, :search_params

  def initialize(search_response, search_params)
    @search_response = search_response
    @search_params = search_params
  end

  def organisations
    if search_keywords.empty?
      Search::Solr.get_organisations.keys
    else
      slugs = search_response["facet_counts"]["facet_fields"]["organization"]

      slugs = slugs.values_at(* slugs.each_index.select(&:even?))

      results_organisations = []
      slugs.each do |slug|
        results_organisations << Search::Solr.get_organisation(slug)["response"]["docs"].first["title"]
      end

      results_organisations.sort
    end
  end

  def topic_options
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

  def format_options
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

  def search_keywords
    search_params.fetch("q", "")
  end
end
