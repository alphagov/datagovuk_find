class SearchController < ApplicationController
  def search
    @query = params["q"]
    datasets = Dataset.search({ q: @query })
    @results = datasets.datasets
    @num_results = datasets.num_results
    @sorted_by = sort
    @location = location
  end

  def tips

  end

  private
  def sort
    sort = params["sortby"]
    %w(best recent viewed).include?(sort) ? sort : nil
  end

  def location
    loc = params["location"]
    loc.blank? ? nil : loc
  end
end
