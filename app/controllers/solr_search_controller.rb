class SolrSearchController < ApplicationController
  def search
    @sort = params["sort"]

    @presenter = SearchPresenter.new(solr_search_response, params)

    @num_results = solr_search_response["response"]["numFound"]
    @datasets = Kaminari.paginate_array(
      solr_search_response["response"]["docs"],
      total_count: @num_results,
    ).page(params[:page])
     .per(Search::Solr::RESULTS_PER_PAGE)
  end

private

  def solr_search_response
    @solr_search_response ||= Search::Solr.search(params)
  end
end
