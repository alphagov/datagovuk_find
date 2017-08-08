require 'uri'

class DatasetsController < ApplicationController
  include DatasetsHelper

  def show
    @dataset = current_dataset

    render :template => "errors/not_found", :status => 404 if @dataset.empty?

    @query = get_referrer_query
    @related_datasets = Dataset.search(related_datasets_query)
  end

  private

  def current_dataset
    Dataset.get({id: params[:id]})._source
  end

  def related_datasets_query
    {
      size: 4,
      query: {
        more_like_this: {
          fields: %w(title summary description organisation^2 location*^2),
          ids: [params[:id]],
          min_term_freq: 1,
          min_doc_freq: 1
        }
      }
    }
  end

  def get_referrer_query
    unless request.referer.nil?
      referer_host = URI(request.referer).host.to_s
      app_host = URI(request.host).to_s
      referer_query = URI(request.referer).query

      referer_query if referer_host == app_host
    end
  end
end
