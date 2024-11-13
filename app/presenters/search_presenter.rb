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
      slugs = facet_values("organization")

      results_organisations = slugs.map do |slug|
        Search::Solr.get_organisation(slug)["response"]["docs"].first["title"]
      end

      results_organisations.sort
    end
  end

  def topic_options
    if search_keywords.empty?
      TOPIC_MAPPINGS.keys
    else
      tokenized_topics = facet_values("extras_theme-primary")

      TOPIC_MAPPINGS.select { |_, tokens| (tokenized_topics & tokens).any? }.keys
    end
  end

  def format_options
    if search_keywords.empty?
      Search::Solr::FORMAT_MAPPINGS.keys
    else
      raw_formats = facet_values("res_format")

      main_formats = (cleaned_formats(raw_formats) & Search::Solr::FORMAT_MAPPINGS.keys).sort
    end
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

private

  def facet_values(facet_name)
    counts = search_response.dig("facet_counts", "facet_fields", facet_name)
    counts.values_at(* counts.each_index.select(&:even?))
  end

  def cleaned_formats(raw_formats)
    cleaned_formats = raw_formats.map do |raw_format|
      raw_format.strip.delete_prefix(".").delete_suffix(".")
        .gsub(/\Ahttps:\/\/www\.iana\.org\/assignments\/media-types\/(?:text|application)\//, "")
        .delete_prefix("OGC ")
        .upcase
    end

    cleaned_formats.uniq
  end
end
