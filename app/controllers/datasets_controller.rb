class DatasetsController < LoggedAreaController
  include DatasetsHelper
  include QueryBuilder

  def show
    @dataset = dataset
    @timeseries_datafiles = @dataset.timeseries_datafiles
    @non_timeseries_datafiles = @dataset.non_timeseries_datafiles
    @referer_query = referer_query
    @related_datasets = related_datasets
  rescue => e
    handle_error(e)
  end

  private

  def related_datasets
    query = related_to_query(@dataset._id)
    Dataset.related(query)
  end

  def dataset
    query = get_query(name: params[:name])
    dataset = Dataset.get(query)
    raise 'Metadata missing' if dataset.title.blank?
    dataset
  end

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
