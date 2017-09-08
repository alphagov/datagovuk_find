class DatasetsController < ApplicationController
  include DatasetsHelper
  include QueryBuilder

  def show
    begin
      query = get_query(name: params[:name])
      @dataset = Dataset.get(query)
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
