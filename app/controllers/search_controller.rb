class SearchController < LoggedAreaController
  before_action :search_for_dataset, only: [:search]
  before_action :make_available_to_js, only: [:search]

  def search
    @query = params['q'] || ''
    @sort = params['sort']
    @organisation = params.dig(:filters, :publisher)
    @location = params.dig(:filters, :location)
    @format = params.dig(:filters, :format)
    @topic = params.dig(:filters, :topic)
    @licence = params.dig(:filters, :licence)
    @datasets = @search.page(page_number)
  end

  private

  def search_for_dataset
    query = Search::Query.search(params)
    @search = Dataset.search(query)
    @num_results = @search.results.total_count
  end

  def make_available_to_js
    gon.publishers = Dataset.publishers
    gon.locations = Dataset.locations
  end

  def page_number
    page = params['page']
    page && page.to_i.positive? ? page.to_i : 1
  end
end
