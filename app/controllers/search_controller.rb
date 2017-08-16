class SearchController < ApplicationController
  include QueryBuilder

  def search
    @query = params["q"] || ''
    @sort = params['sort']
    @organisation = params['publisher']
    @location = params['location']
    @search = Dataset.search(search_query(params))

    @num_results = @search.results.total_count
    @datasets = @search.page(page_number)
  end

  def tips
  end

  private

  def page_number
    page = params["page"]

    if page && page.to_i > 0
      page.to_i
    else
      1
    end
  end

end
