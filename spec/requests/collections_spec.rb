require "rails_helper"

RSpec.describe "Collections", type: :request do
  before do
    allow(Rails.configuration.x).to receive(:generated_collections_location).and_return("app/views/generated/collections")
  end

  describe "visiting a collection topic path" do
    let(:collection_path) { "/collections/business-and-economy/bank-of-england-interest-rates" }
    it "returns success response" do
      get collection_path

      expect(response).to have_http_status(:ok)
    end

    it "shows the collection title" do
      get collection_path

      expect(response.body).to include("Bank of England interest rates")
    end

    it "invalid path shows 404" do
      get "/collections/business-and-economy/invalid-topic"

      expect(response).to have_http_status(:not_found)
    end
  end

  context "when version_2_collections feature flag is disabled" do
    it "returns 404 for non-existent collection paths" do
      get "/collections/non-existent-collection/some-topic"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "visiting a collection root path" do
    let(:collection_root_path) { "/collections/business-and-economy" }
    it "returns redirect response" do
      get collection_root_path

      expect(response).to redirect_to("/collections/business-and-economy/agricultural-commodity-prices")
    end

    it "invalid path shows 404" do
      get "/collections/invalid-collection"

      expect(response).to have_http_status(:not_found)
    end
  end
end
