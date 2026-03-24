module CollectionHelper
  HEADLINE_ITEM_KEYS = %w[subtitle description value analysis trend value_change percent_change].freeze

  def chart_partial_path(visualisation_type)
    {
      "line" => "v2/collection/charts/line_chart",
      "headline" => "v2/collection/charts/headline/headline",
      "bar" => "v2/collection/charts/bar_chart",
    }.fetch(visualisation_type)
  end

  def chart_locals(chart_data)
    case chart_data["visualisation_type"]
    when "line"
      {
        max_value: chart_data["max_value"],
        title: chart_data["title"],
        empty_description: "No data available",
        number_base: chart_data["number_base"],
        suffix: chart_data["visualisation_suffix"],
        min: chart_data["min_value"],
        data_series: chart_data["series"],
      }
    when "headline"
      {
        title: chart_data["title"],
        source: chart_data["source"],
        items: chart_data["items"].map { |item| item.slice(*HEADLINE_ITEM_KEYS).symbolize_keys },
      }
    when "bar"
      {
        title: chart_data["title"],
        data: chart_data["data"],
        size: 15,
      }
    end
  end
end
