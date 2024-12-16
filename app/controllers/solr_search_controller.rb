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
    @solr_search_response ||= begin
      Search::Solr.search(params)
    rescue Search::Solr::NoSearchTermsError
      no_results_found
    rescue RSolr::Error::Http => e
      handle_solr_http_error(e)
    end
  end

  def handle_solr_http_error(error)
    if error.response[:status].to_s.start_with?("4")
      no_results_found
    else
      raise error
    end
  end

  def no_results_found
    { "response" => { "numFound" => 0, "docs" => [] } }
  end
end
