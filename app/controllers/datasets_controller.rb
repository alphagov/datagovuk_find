require 'cgi'

class DatasetsController < ApplicationController
  include DatasetsHelper

  def show
    @query = get_query_referral
    @dataset = current_dataset
  end

  private

  def current_dataset
    Dataset.get({id: params[:id]})._source
  end

  def get_query_referral
    referrer = request.referrer || ''
    path = URI(referrer).path
    query = URI(referrer).query

    path != '/search' ?
        nil :
        CGI::parse(query)['q'].join
  end
end
