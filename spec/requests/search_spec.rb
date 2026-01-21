require "rails_helper"

RSpec.describe "Search", type: :request do
  describe "GET /search" do
    before do
      allow(Search::Solr).to receive(:search).and_return(JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_response.json").to_s)))
      allow(Search::Solr).to receive(:get_organisations).and_return({
        "Aberdeen City Council" => "aberdeen-city-council",
        "Ministry of Housing, Communities and Local Government" => "department-for-communities-and-local-government",
        "Academics" => "academics",
      })
      get search_path
    end

    it "returns success response" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the search page" do
      expect(response.body).to include("Search results")
    end

    it "renders a govuk notification banner" do
      expect(response.body).to include("govuk-notification-banner-title")
    end

    it "renders the survey link" do
      expect(response.body).to include("https://forms.gle/9De6rHdmUyVRVTU2A")
    end
  end
end
