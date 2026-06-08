require "rails_helper"

RSpec.describe "pages", type: :request do
  describe "GET /publishers" do
    before do
      get publishers_path
    end

    it "returns success response" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the publishers page" do
      expect(response.body).to include(I18n.t(".pages.publishers.publish_your_data"))
    end
  end

  describe "GET /site-changes" do
    before do
      get site_changes_path
    end

    it "returns success response" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the site changes page" do
      expect(response.body).to include("Update about changes to data.gov.uk")
    end
  end

  describe "GET /ckan_maintenance" do
    before do
      get ckan_maintenance_path
    end

    it "returns failed response" do
      expect(response).to have_http_status(:service_unavailable)
    end

    it "renders the ckan maintenance page" do
      expect(response.body).to include("Data.gov.uk publishing freeze")
    end
  end
end
