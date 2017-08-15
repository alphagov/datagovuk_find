class SearchController < ApplicationController
  def search
    @query = params["q"] || ''
    # these instance vars are used by the search template to display
    # the number of results stuff.
    @sort = params['sort']
    @organisation = params['publisher']
    @location = params['location']
    @search = Dataset.search(search_query)
    @num_results = @search.results.total_count
    @datasets = @search.page(page_number)
  end

  def tips
  end

  private
  def search_query
    query = {
      query: {
        bool: {}
      }
    }
    # Elastic search returns results sorted by relevance (aka match) by default

    if @sort == "recent"
      query[:sort] = { "updated_at": { "order": "desc" }}
    end

    unless @organisation.blank?
      query[:query][:bool][:must] ||= []
      query[:query][:bool][:must] << publisher_filter_query
    end

    unless @location.blank?
      query[:query][:bool][:filter] ||= []
      query[:query][:bool][:filter] << {term: {location1: params['location']}}
    end

    unless @query.blank?
      query[:query][:bool][:must] ||= []
      query[:query][:bool][:must] << multi_match_query
    end

    query
  end

  def multi_match_query
    {
      multi_match: {
        query: @query,
        fields: %w(title summary description organisation^2 location*^2)
      }
    }
  end

  def publisher_filter_query
    {
      nested: {
        path: "organisation",
        query: {
          bool: {
            must: [
              {
                match: {
                  "organisation.title": @organisation
                }
              }
            ]
          }
        }
      }
    }
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
