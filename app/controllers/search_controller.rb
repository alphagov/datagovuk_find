class SearchController < ApplicationController
  def search
    @query = params["q"] || ''
    @sorted_by = sort
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

    case @sorted_by
      when "recent"
        query[:sort] = {updated_at: :desc}
    end

    unless params['publisher'].blank?
      query[:query][:bool][:must] ||= []
      query[:query][:bool][:must] << publisher_filter_query
    end

    unless params['location'].blank?
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
                  "organisation.title": params['publisher']
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

  def sort
    sort = params["sortby"]
    %w(best recent viewed).include?(sort) ? sort : nil
  end
end
