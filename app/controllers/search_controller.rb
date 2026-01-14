class SearchController < ApplicationController
  before_action :validate_search_params!

  LATIN_AND_NUMBERS_REGEX = /[\p{Latin}\p{N}\s]/
  SPECIAL_CHARS_REGEX = /[£$!%&'*+_=\-.\/,:;"`?<>@#^(){}\[\]~|\\]/
  VALID_SEARCH_REGEX = /\A(?:#{LATIN_AND_NUMBERS_REGEX.source}|#{SPECIAL_CHARS_REGEX.source})+\z/

  def search
    @sort = search_params[:sort]

    @presenter = SearchPresenter.new(solr_search_response, search_params)

    @num_results = solr_search_response["response"]["numFound"]

    @datasets = Kaminari.paginate_array(
      solr_search_response["response"]["docs"],
      total_count: @num_results,
    )
    .page(search_params[:page])
    .per(Search::Solr::RESULTS_PER_PAGE)
  end

private

  def validate_search_params!
    query = params[:q].to_s

    redirect_to root_path unless query.empty? || query.match?(VALID_SEARCH_REGEX)
  end

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

  def search_params
    params.permit(
      :q,
      :sort,
      :page,
      filters: %i[publisher topic format licence_code],
    )
  end
end
