class SearchController < ApplicationController
  def search
    @query = params["q"]
    @search = Dataset.search(@query)
    @sorted_by = sort
    @location = location
    @organisation = organisation
    # @datasets = @search.page(page_number)
    @datasets =  process_results(@search.results)
    @num_results = @datasets.count
  end

  def tips
  end

  private
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

  def process_results(results)
    results = process_organisation(results)
    process_location(results)
  end

  def process_organisation(results)
    if @organisation.nil?
      results
    else
      results.select { |r| r.organisation.title == @organisation }
    end
  end

  def process_location(results)
    if @location.nil?
      results
    else
      results.select { |r| r.location1 == @location }
    end
  end
end
