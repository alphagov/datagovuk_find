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
        multi_match: {
          query: @query,
          fields: %w(title summary description organisation^2 location*^2)
        }
      }
    }

    if @sorted_by
      sort_field = {}

      case @sorted_by
      when "recent"
        sort_field = { updated_at: :desc }
      end

      base_search_query[:sort] = sort_field
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
