class DatasetsController < ApplicationController
  include DatasetsHelper

  def show
    @dataset = Dataset.get_by_uuid(uuid: params[:uuid])
    @timeseries_datafiles = @dataset.timeseries_datafiles
    @non_timeseries_datafiles = @dataset.non_timeseries_datafiles
    @referer_query = referer_query
    @related_datasets = Dataset.related(@dataset.id)

    if request_to_outdated_url?
      return redirect_to newest_dataset_path, status: :moved_permanently
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
    request.path != newest_dataset_path
  end

  def newest_dataset_path
    dataset_path(@dataset.uuid, @dataset.name)
  end
end
