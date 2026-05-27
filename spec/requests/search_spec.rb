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
      expect(response.body).to include("Search directory")
    end

    it "returns no results section" do
      expect(response.body).not_to match(/<div class="dgu-results__result">/)
    end

    context "when all parameters are empty" do
      before do
        allow(Search::Solr).to receive(:search).and_return(JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_response.json").to_s)))
        get search_path(q: "", organisation: "", format: "")
      end

      it "shows all results found" do
        expect(response.body).to match(/<span class="dgu-results__summary">.*<span class="govuk-body-s govuk-!-font-weight-bold">2<\/span>.*results found.*<\/span>/m)
      end
    end

    context "when the q parameter is empty" do
      before do
        get search_path(q: "")
        allow(Search::Solr).to receive(:search).and_return(JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_response.json").to_s)))
      end

      it "returns all search results" do
        expect(response.body).to match(/Displaying <b>all 2<\/b> datasets/)
      end
    end

    context "when the q parameter is present" do
      before do
        allow(Search::Solr).to receive(:get_organisation).with(anything).and_return(
          "response" => {
            "numFound" => 1,
            "docs" => [],
          },
        )
        allow(Search::Solr).to receive(:get_organisations).and_return({
          "Aberdeen City Council" => "aberdeen-city-council",
          "Ministry of Housing, Communities and Local Government" => "department-for-communities-and-local-government",
          "Academics" => "academics",
        })
        get search_path(q: "abc")
      end

      it "returns search results" do
        expect(response.body).to match(/Displaying <b>all 2<\/b> datasets/)
      end
    end
  end
end
