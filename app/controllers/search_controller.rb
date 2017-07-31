class SearchController < ApplicationController
  def search
    @query = params["q"]
    @sorted_by = sort
    @location = location
    results = Dataset.search({ q: @query })
    @datasets = results.datasets
    @num_results = results.num_results

    sort_datasets!
  end

  private
  def sort
    sort = params["sortby"]
    %w(best recent viewed).include?(sort) ? sort : nil
  end

  def sort_datasets!
    return unless @sorted_by

    case @sorted_by
    when "recent"
      @dataset = @datasets.sort_by { |d| d.created_at }
    end
  end

  def location
    loc = params["location"]
    loc.blank? ? nil : loc
  end
end
