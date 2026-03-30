require "rails_helper"

RSpec.describe "chart download", type: :request do
  describe "GET /collections/:collection/:topic/charts/:chart" do
    let(:chart) { "test-chart" }
    let(:collection) { "test-collection" }
    let(:topic) { "test-topic" }
    let(:subject) { get chart_download_path(chart: chart, collection: collection, topic: topic) }

    before do
      allow(Rails.configuration.x).to receive(:visualisations_data_location).and_return("spec/fixtures/content/data")
      subject
    end

    it "returns successfully" do
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq("text/csv")
    end

    it "returns the correct CSV file" do
      expect(response.body.gsub("\r\n", "\n")).to eq(File.read(Rails.root.join("spec/fixtures/content/data/test-topic/test-chart.csv")).gsub("\r\n", "\n"))
    end

    context "chart does not exist" do
      let(:chart) { "non-existent-chart" }
      it "returns 404 for non-existent chart" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
