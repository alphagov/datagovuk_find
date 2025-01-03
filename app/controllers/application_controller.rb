class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, prepend: true
  rescue_from SolrDataset::NotFound, with: :render_not_found
  rescue_from SolrDatafile::NotFound, with: :render_not_found

  def render_not_found
    render "errors/not_found", status: :not_found
  end
end
