class SearchPresenter
  TOPIC_MAPPINGS = {
    "Business and economy" => %w[busi businessandeconomi economi],
    "Crime and justice" => %w[crime crimeandjustic justic],
    "Defence" => %w[defenc],
    "Digital services performance" => %w[digit digitalservicesperform perform servic],
    "Education" => %w[educ],
    "Environment" => %w[environ],
    "Government" => %w[govern],
    "Government reference data" => %w[data governmentreferencedata refer],
    "Government spending" => %w[governmentspend spend],
    "Health" => %w[health],
    "Mapping" => %w[map],
    "Society" => %w[societi],
    "Towns and cities" => %w[city town townsandc],
    "Transport" => %w[transport],
  }.freeze

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
    if search_keywords.empty?
      TOPIC_MAPPINGS.keys
    else
      topic_counts = search_response.dig("facet_counts", "facet_fields", "extras_theme-primary")
      tokenized_topics = topic_counts.values_at(* topic_counts.each_index.select(&:even?))

      TOPIC_MAPPINGS.select { |_, tokens| (tokenized_topics & tokens).any? }.keys
    end
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

  def selected_publisher
    search_params.dig(:filters, :publisher)
  end

  def selected_topic
    search_params.dig(:filters, :topic)
  end

  def selected_format
    search_params.dig(:filters, :format)
  end
end
