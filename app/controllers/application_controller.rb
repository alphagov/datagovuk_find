class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, prepend: true
  before_action :restrict_request_format
  rescue_from SolrDataset::NotFound, with: :render_not_found
  rescue_from SolrDatafile::NotFound, with: :render_not_found

  rescue_from RSolr::Error::ConnectionRefused do |exception|
    Sentry.capture_exception(exception) if defined?(Sentry)

    render "errors/service_unavailable_error", status: :service_unavailable
  end

  def render_not_found
    render "errors/not_found", status: :not_found
  end

  def restrict_request_format
    request.format = :html
  end
end
