class DatasetsController < LoggedAreaController
  include DatasetsHelper

  def show
    @dataset = Dataset.get_by_short_id(short_id: params[:short_id])
    @timeseries_datafiles = @dataset.timeseries_datafiles
    @non_timeseries_datafiles = @dataset.non_timeseries_datafiles
    @referer_query = referer_query
    @related_datasets = Dataset.related(@dataset._id)

    if request_to_outdated_url?
      return redirect_to newest_dataset_path, status: :moved_permanently
    end

  rescue => e
    handle_error(e)
  end

  private

  def handle_error(e)
    Rails.logger.debug 'ERROR! => ' + e.message
    e.backtrace.each { |line| logger.error line }
    render template: 'errors/not_found', status: 404
  end

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
    dataset_path(@dataset.short_id, @dataset.name)
  end

end
