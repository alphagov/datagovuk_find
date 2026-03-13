class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, prepend: true
  before_action :authenticate, :restrict_request_format
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

  private

  def authenticate
    # short–circuit the filter for the health‑check URL
    true if request.path == "/healthz"
    # (or: params[:controller] == "rails/health" && params[:action] == "show")

    if ENV["BASIC_AUTH_USERNAME"].present? && ENV["BASIC_AUTH_PASSWORD"].present?
      authenticate_or_request_with_http_basic do |username, password|
        ActiveSupport::SecurityUtils.secure_compare(username, ENV["BASIC_AUTH_USERNAME"]) &
          ActiveSupport::SecurityUtils.secure_compare(password, ENV["BASIC_AUTH_PASSWORD"])
      end
    else
      logger.warn "BASIC_AUTH_USERNAME and BASIC_AUTH_PASSWORD environment variables are not set. Basic authentication is disabled."
      true
    end
  end
end
