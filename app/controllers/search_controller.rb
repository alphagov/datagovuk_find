class SearchController < ApplicationController
  def search
    @query = params["q"]
    @sorted_by = sort
    @location = location
    @organisation = organisation

    @search = Dataset.search(search_query)
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
      base_search_query[:query][:bool][:filter] << { match: { :"organisation.title" => @organisation } }
    end

    base_search_query
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

  def organisation
    org = params["org"] || params["input-autocomplete"]
    org.blank? ? nil : org
  end
end
