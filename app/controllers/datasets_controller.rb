
class DatasetsController < ApplicationController
  include DatasetsHelper
  include QueryBuilder

  def show
    begin
      query = get_query(params[:name])
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

  def preview
    @preview = RestClient.get(preview_url(params[:file_id]))
    render json: @preview
  rescue
    render json: { "error": "No preview available" }, status: 404
  end

  private

  def handle_error(e)
    Rails.logger.debug "ERROR! => " + e.message
    e.backtrace.each { |line| logger.error line }
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
