class SearchController < ApplicationController
  def search
    @query = params["q"]
    datasets = Dataset.search({ q: @query })
    @results = datasets.datasets
    @num_results = datasets.num_results
  end
end
