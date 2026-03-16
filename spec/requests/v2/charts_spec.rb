require "rails_helper"

RSpec.describe "chart download", type: :request do
  describe "GET /charts/:chart/download" do
    let(:chart) { "test-collection" }
    let(:collection) { "test-collection" }
    let(:subject) { get chart_download_path(chart: chart, collection: collection) }

    before do
      allow(Rails.configuration.x).to receive(:visualisations_data_location).and_return("spec/fixtures/content/data")
      subject
    end

    it "returns successfully" do
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq("text/csv")
    end

    it "returns the correct CSV file" do
      expect(response.body).to eq(File.read(Rails.root.join("spec/fixtures/content/data/test-collection/test-collection.csv")))
    end

    context "chart does not exist" do
      let(:chart) { "non-existent-chart" }
      it "returns 404 for non-existent chart" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
