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
    query = URI(request.referrer).query
    CGI::parse(query)['q'].join
  end
end
