require "rails_helper"

RSpec.describe "pages", type: :request do
  shared_examples "renders the notification banner" do
    it "renders the publishers page" do
      expect(response.body).to include(I18n.t("pages.publishers.publish_your_data"))
    end

    it "renders a govuk notification banner" do
      expect(response.body).to include("govuk-notification-banner-title")
    end

    it "renders the survey link" do
      expect(response.body).to include("https://forms.gle/9De6rHdmUyVRVTU2A")
    end
  end

  describe "GET /" do
    before do
      get root_path
    end

    it "returns success response" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the home page" do
      expect(response.body).to include(I18n.t("pages.home.find_open_data"))
    end

    include_examples "renders the notification banner"
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

    include_examples "renders the notification banner"
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

    include_examples "renders the notification banner"
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

    include_examples "renders the notification banner"
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

    include_examples "renders the notification banner"
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

    include_examples "renders the notification banner"
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

    include_examples "renders the notification banner"
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

    include_examples "renders the notification banner"
  end

  describe "GET /privacy" do
    before do
      get privacy_path
    end

    it "returns success response" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the privacy page" do
      expect(response.body).to include("Privacy")
    end

    include_examples "renders the notification banner"
  end
end
