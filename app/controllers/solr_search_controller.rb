class SolrSearchController < ApplicationController
  def search
    @sort = params["sort"]

    @presenter = SearchPresenter.new(solr_search_response, params)
    @datasets = solr_search_response["response"]["docs"]
    @num_results = solr_search_response["response"]["numFound"]
  end

private

  def solr_search_response
    @solr_search_response ||= Search::Solr.search(params)
  end
end
