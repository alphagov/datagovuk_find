require "rails_helper"

RSpec.describe SearchPresenter do
  describe "#topic_options" do
    it "returns a full list if no query is specified" do
      query_result = { "responseHeader" => {
        "status" => 0,
        "params" => { "q" => "*:*", "wt" => "json" },
      } }

      presenter = described_class.new(query_result, {})

      expect(presenter.topic_options).to eql([
        "Business and economy",
        "Crime and justice",
        "Defence",
        "Digital service performance",
        "Education",
        "Environment",
        "Government",
        "Government reference data",
        "Government spending",
        "Health",
        "Mapping",
        "Society",
        "Towns and cities",
        "Transport",
      ])
    end
  end

  describe "#format_options" do
    it "returns a full list if no query is specified" do
      query_result = { "responseHeader" => {
        "status" => 0,
        "params" => { "q" => "*:*", "wt" => "json" },
      } }

      presenter = described_class.new(query_result, {})

      expect(presenter.format_options).to eql(%w[
        CSV
        GEOJSON
        HTML
        KML
        PDF
        WMS
        XLS
        XML
        ZIP
      ])
    end
  end
end
