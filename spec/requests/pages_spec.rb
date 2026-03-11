require "rails_helper"

RSpec.describe "pages", type: :request do
  describe "GET /" do
    before do
      get root_path
    end

    it "returns success response" do
      expect(response).to have_http_status(:ok)
    end
  end

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

  describe "GET /support" do
    before do
      get support_path
    end

    it "returns success response" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the support page" do
      expect(response.body).to include("Support")
    end
  end

  describe "GET /about" do
    before do
      get about_path
    end

    it "returns success response" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the about page" do
      expect(response.body).to include("About")
    end
  end

  describe "GET /accessibility" do
    before do
      get accessibility_path
    end

    it "returns success response" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the accessibility page" do
      expect(response.body).to include("Accessibility")
    end
  end

  describe "GET /cookies" do
    before do
      get cookies_path
    end

    it "returns success response" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the cookies page" do
      expect(response.body).to include("Cookies")
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

  describe "GET /terms" do
    before do
      get terms_path
    end

    it "returns success response" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the privacy page" do
      expect(response.body).to include("Terms and conditions")
      expect(response.body).to include("Privacy")
    end
  end

  describe "GET /roadmap" do
    before do
      get roadmap_path
    end

    it "returns success response" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the roadmap page" do
      expect(response.body).to include("data.gov.uk roadmap")
    end
  end

  describe "GET /team" do
    before do
      get team_path
    end

    it "returns success response" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the team page" do
      expect(response.body).to include("data.gov.uk team")
    end
  end

  describe "GET /plan" do
    before do
      get plan_path
    end

    it "returns success response" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the plan page" do
      expect(response.body).to include("Our plan for data.gov.uk")
    end
  end
end
