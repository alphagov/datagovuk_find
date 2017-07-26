class SearchController < ApplicationController
  def search
    @query = params["q"]
    @results = Dataset.search(@query).datasets
  end
end
