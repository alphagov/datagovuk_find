require 'faraday'
require 'faraday_middleware'
require 'csv'

class DatasetsController < LoggedAreaController
  include DatasetsHelper
  include QueryBuilder

  def show
    begin
      query = get_query(name: params[:name])
      @dataset = Dataset.get(query)
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
    slug = get_query(name: params[:name])
    @dataset = Dataset.get(slug)
    uuid = params[:uuid]

    datafile = @dataset.datafiles.select do |f|
      f.uuid == uuid
    end

    conn = Faraday.new do |faraday|
      faraday.use FaradayMiddleware::FollowRedirects, limit: 3
      faraday.adapter :net_http
    end
    conn.headers = {'Range' => "bytes=0-1024"}
    response = conn.get do |req|
      req.url datafile[0].url
      req.options.timeout = 10
    end

    csv = response.body.rpartition("\n")[0]

    @content_type = 'CSV'
    @preview = {
      'dataset_name' => @dataset.name,
      'datafile_link' => datafile[0].url,
      'datafile_name' => datafile[0].name,
      'body' => CSV.parse(csv)
    }
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

  def request_dataset(preview)
    dataset_id = preview['meta']['dataset_id']
    query = get_query(id: dataset_id)
    Dataset.get(query)
  end
end
