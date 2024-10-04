class SolrDatasetsController < ApplicationController
  def show
    solr_response = Search::Solr.get_by_uuid(uuid: params[:uuid])
    @dataset = SolrDataset.new(solr_response["response"]["docs"].first)
  end
end
