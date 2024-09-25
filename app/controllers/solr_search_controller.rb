class SolrSearchController < ApplicationController
  before_action :search_for_dataset, only: [:search]

  def search; end

private

  def search_for_dataset
    query = Search::Solr.search(params)

    @datasets = query["response"]["docs"]
    @num_results = query["response"]["numFound"]
  end
end
