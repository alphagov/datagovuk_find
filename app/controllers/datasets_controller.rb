require 'uri'

class DatasetsController < ApplicationController
  include DatasetsHelper

  def show
    @query = get_referrer_query
    @dataset = current_dataset
  end

  private

  def current_dataset
    Dataset.get({id: params[:id]})._source
  end

  def get_referrer_query
    unless request.referer.nil?
      referer = request.referer
      referer_host = URI(referer).host.to_s
      referer_query = URI(referer).query
      app_host = URI(request.host).to_s

      referer_query if referer_host == app_host
    end
  end
end
