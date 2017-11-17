class DatasetsController < LoggedAreaController
  include DatasetsHelper

  def show
    @dataset = Dataset.get_by(uuid: params[:uuid])
    @timeseries_datafiles = @dataset.timeseries_datafiles
    @non_timeseries_datafiles = @dataset.non_timeseries_datafiles
    @referer_query = referer_query
    @related_datasets = Dataset.related(@dataset._id)
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
end
