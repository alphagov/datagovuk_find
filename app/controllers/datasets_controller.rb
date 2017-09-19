class DatasetsController < LoggedAreaController
  include DatasetsHelper
  include QueryBuilder

  def show
    begin
      @dataset = Dataset.get_by(name: params[:name])
      @timeseries_datafiles = @dataset.timeseries_datafiles
      @non_timeseries_datafiles = @dataset.non_timeseries_datafiles
      raise 'Metadata missing' if @dataset.title.blank?
    rescue => e
      handle_error(e)
    end

    @referrer = referrer

    unless @dataset.nil?
      query = related_to_query(@dataset._id)
      @related_datasets = Dataset.related(query)
    end
  end

  def preview
    @dataset = Dataset.get_by(name: params[:name])
    @datafile = @dataset.datafiles.find { |f| f.uuid == params[:uuid] }
    @preview = @datafile.preview
  end

  private

  def handle_error(e)
    Rails.logger.debug "ERROR! => " + e.message
    e.backtrace.each {|line| logger.error line}
    render :template => "errors/not_found", :status => 404
  end

  def referrer
    unless request.referer.nil?
      referer_host = URI(request.referer).host.to_s
      app_host = URI(request.host).to_s
      referer_query = URI(request.referer).query

      referer_query if referer_host == app_host
    end
  end
end
