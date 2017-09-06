class SearchController < ApplicationController
  include QueryBuilder

  def search
    @query = params['q'] || ''
    @sort = params['sort']
    @organisation = params['publisher']
    @location = params['location']
    @search = Dataset.search(search_query(params))
    @num_results = @search.results.total_count
    @datasets = @search.page(page_number)

    gon.publishers = get_publishers
    gon.locations = get_locations
  end

  def tips
    render(:layout => "layouts/application")
  end

  private

  def get_publishers
    results = Dataset.search(publishers_aggregation_query)

    results.response.aggregations.organisations.org_titles.buckets.map do |bucket|
      "#{bucket[:key]} - #{bucket[:doc_count]} #{pluralize_count_for(bucket[:doc_count])}"
    end
  end

  def get_locations
    results = Dataset.search(locations_aggregation_query)

    results.response.aggregations.locations.buckets.map do |bucket|
      "#{bucket[:key]} - #{bucket[:doc_count]} #{pluralize_count_for(bucket[:doc_count])}"
    end
  end

  def pluralize_count_for(doc_count)
    doc_count == 1 ?
      'hit' :
      'hits'
  end

  def page_number
    page = params["page"]

    if page && page.to_i > 0
      page.to_i
    else
      1
    end
  end

end


