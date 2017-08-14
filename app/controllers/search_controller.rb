class SearchController < ApplicationController
  def search
    @query = params["q"] || ''
    @sorted_by = sort
    @location = location
    @organisation =  params['publisher']
    @search =
      if params['publisher']
        Dataset.search(org_search)
      else
        Dataset.search(search_query)
      end
    @num_results = @search.results.total_count
    @datasets = @search.page(page_number)
  end

  def tips
  end

  private
  def search_query
    base_search_query = {
      query: {
        bool: {
          must: {
            multi_match: {
              query: @query,
              fields: %w(title summary description organisation^2 location*^2)
            }
          }
        }
      }
    }

    case @sorted_by
    when "recent"
      base_search_query[:sort] = { updated_at: :desc }
    end

    if @location
      base_search_query[:query][:bool][:filter] ||= []
      base_search_query[:query][:bool][:filter] << { term: { location1: @location } }
    end

    if @organisation
      base_search_query[:query][:bool][:filter] ||= []
      base_search_query[:query][:bool][:filter] << { term: { 'organisation.title' => @organisation } }
    end

    base_search_query
  end

  def org_search
    {
  query: {
    bool: {
      must: [
        {
          nested: {
            path: "organisation",
            query: {
              bool: {
                must: [
                  {
                    match: {
                      "organisation.title": params['publisher']
                    }
                  }\
                ]
              }
            }
          }
        }
      ]
}}}
  end

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
