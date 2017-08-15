
class DatasetsController < ApplicationController
  include DatasetsHelper

  def show
    begin
      query = QueryBuilder.get(params[:name])
      @dataset = Dataset.get(query)
      raise 'Metadata missing' if @dataset.title.blank?
    rescue => e
      handle_error(e)
    end

    @query = referrer_query

    unless @dataset.nil?
      query = QueryBuilder.related_to(@dataset._id)
      @related_datasets = Dataset.related(query)
    end
  end

  private

  def handle_error(e)
    Rails.logger.debug "ERROR! => " + e.message
    e.backtrace.each { |line| logger.error line }
    render :template => "errors/not_found", :status => 404
  end

  def referrer_query
    unless request.referer.nil?
      referer_host = URI(request.referer).host.to_s
      app_host = URI(request.host).to_s
      referer_query = URI(request.referer).query

      referer_query if referer_host == app_host
    end
  end
end
