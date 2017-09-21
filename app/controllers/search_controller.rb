class SearchController < LoggedAreaController
  include QueryBuilder

  before_action :search_for_dataset, only: [:search]
  before_action :make_available_to_js, only: [:search]

  def search
    @query = params['q'] || ''
    @sort = params['sort']
    @organisation = params['publisher']
    @location = params['location']
    @datasets = @search.page(page_number)
  end

  def tips
    render(layout: 'layouts/application')
  end

  private

  def search_for_dataset
    @search = Dataset.search(search_query(params))
    @num_results = @search.results.total_count
  end

  def make_available_to_js
    gon.publishers = Datasets.publishers(publishers_aggregation_query)
    gon.locations = Datasets.locations(locations_aggregation_query)
  end

  def page_number
    page = params['page']
    page && page.to_i.positive? ? page.to_i : 1
  end
end
