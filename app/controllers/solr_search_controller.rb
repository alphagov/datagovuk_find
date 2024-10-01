class SolrSearchController < ApplicationController
  before_action :search_for_dataset, only: [:search]

  def search
    @sort = params["sort"]
  end

private

  def search_for_dataset
    query = Search::Solr.search(params)

    @datasets = query["response"]["docs"].map do |doc|
      SolrDataset.new(doc)
    end

    @num_results = query["response"]["numFound"]
  end
end
