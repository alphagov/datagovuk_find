require "rails_helper"

RSpec.describe "pages", type: :request do
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

    it "renders a govuk notification banner" do
      expect(response.body).to include("govuk-notification-banner-title")
    end

    it "renders the survey link" do
      expect(response.body).to include("https://surveys.publishing.service.gov.uk/s/OSC03D/")
    end
  end
end
