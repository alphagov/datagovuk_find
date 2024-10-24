class SolrSearchController < ApplicationController
  before_action :search_for_dataset, only: [:search]

  def search
    @sort = params["sort"]
  end

private

  def search_for_dataset
    @organisations = Search::Solr.get_organisations
    query = Search::Solr.search(params)

    @datasets = query["response"]["docs"]
    @num_results = query["response"]["numFound"]
    # @organisations = get_organisations(query) if query["facet_counts"].present?
  end

  # def get_organisations(query)
  #   @organisations = []
  #   slugs = query["facet_counts"]["facet_fields"]["organization"]
  #   slugs = slugs.values_at(* slugs.each_index.select {|i| i.even?})

  #   slugs.each do |slug| 
  #     @organisations << Search::Solr.get_organisation_by_slug(slug)["response"]["docs"].first["title"]
  #   end

  #   @organisations.sort
  # end
end
