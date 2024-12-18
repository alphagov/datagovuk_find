class SolrDatasetsController < ApplicationController
  def show
    @dataset = SolrDataset.get_by_uuid(uuid: params[:uuid])

    @referer_query = referer_query

    if request_to_outdated_url?
      redirect_to newest_solr_dataset_path, status: :moved_permanently
    end
  end

private

  def referer_query
    return if request.referer.nil?

    referer_query = URI(request.referer).query

    referer_query if current_host_matches_referer_host
  end

  def current_host_matches_referer_host
    URI(request.host).to_s == URI(request.referer).host.to_s
  end

  def request_to_outdated_url?
    request.path != newest_solr_dataset_path
  end

  def newest_solr_dataset_path
    solr_dataset_path(@dataset.uuid, @dataset.name)
  end
end
