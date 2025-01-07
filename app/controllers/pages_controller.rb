class PagesController < ApplicationController
  def dashboard
    render "errors/not_found", status: :gone
  end

  def ckan_maintenance
    render "ckan_maintenance", status: :service_unavailable
  end

  def home
    expires_in 30.minutes, public: true
  end
end
