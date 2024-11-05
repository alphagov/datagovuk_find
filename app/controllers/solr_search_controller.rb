class SolrSearchController < ApplicationController
  before_action :search_for_dataset, only: [:search]

  def search
    @sort = params["sort"]
  end

private

  def search_for_dataset
    query = Search::Solr.search(params)

    @organisations = get_organisations(query)
    @datasets = query["response"]["docs"]
    @num_results = query["response"]["numFound"]
  end

  def get_organisations(query)
    if params.fetch("q", "").empty?
      Search::Solr.get_organisations.keys
    else
      slugs = query["facet_counts"]["facet_fields"]["organization"]

      slugs = slugs.values_at(* slugs.each_index.select(&:even?))

      results_organisations = []
      slugs.each do |slug|
        results_organisations << Search::Solr.get_organisation(slug)["response"]["docs"].first["title"]
      end

      results_organisations.sort
    end
  end
end
