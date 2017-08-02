class SearchController < ApplicationController
  def search
    @query = params["q"]
    @search = Dataset.search(@query)
    @num_results = @search.results.total
    @sorted_by = sort
    @location = location
    @datasets = @search.page(page_number).results
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

  def sort
    sort = params["sortby"]
    %w(best recent viewed).include?(sort) ? sort : nil
  end

  def location
    loc = params["location"]
    loc.blank? ? nil : loc
  end
end
