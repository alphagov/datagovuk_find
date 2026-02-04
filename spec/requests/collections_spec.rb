require "rails_helper"

RSpec.describe "Collections", type: :request do
  before do
    allow(Rails.configuration.x).to receive(:generated_collections_location).and_return("app/views/generated/collections")
  end

  describe "visiting a collection path" do
    let(:collection_path) { "/collections/land-and-property/property-price-paid" }
    it "returns success response" do
      get collection_path

      expect(response).to have_http_status(:ok)
    end

    it "shows the collection title" do
      get collection_path

      expect(response.body).to include("<h1 class=\"dgu-collection-name govuk-heading-xl\">Land and property</h1>")
    end

    it "shows the collection navigation links" do
      get collection_path

      expect(response.body).to include("Planning data")
      expect(response.body).to include("Property price paid")
    end

    it "invalid path shows 404" do
      get "/collections/land-and-property/invalid-topic"

      expect(response).to have_http_status(:not_found)
    end
  end

  context "when version_2_collections feature flag is disabled" do
    before do
      allow(Rails.configuration.x).to receive(:version_2_collections_enabled).and_return(false)
    end

    it "returns 404 for non-existent collection paths" do
      get "/collections/non-existent-collection/some-topic"

      expect(response).to have_http_status(:not_found)
    end
  end
end
