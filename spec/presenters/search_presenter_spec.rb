require "rails_helper"

RSpec.describe SearchPresenter do
  describe "#topic_options" do
    it "returns a full list if no query is specified" do
      query_response = { "responseHeader" => {
        "status" => 0,
        "params" => { "q" => "*:*", "wt" => "json" },
      } }

      presenter = described_class.new(query_response, {})

      expect(presenter.topic_options).to eql(SearchPresenter::TOPIC_MAPPINGS.keys)
    end

    it "returns a list sorted of topic names for facet tokens" do
      query_response =
        { "responseHeader" => {
            "params" => { "q" => "title:\"dogs\" OR notes:\"dogs\" AND NOT site_id:dgu_organisations" },
          },
          "facet_counts" => {
            "facet_fields" => {
              "extras_theme-primary" => ["societi", 18, "and", 16, "busi", 9, "businessandeconomi", 9, "economi", 9, "environ", 9, "citi", 4, "town", 4, "townsandc", 4, "crime", 3, "crimeandjustic", 3, "justic", 3, "map", 2],
            },
          } }
      presenter = described_class.new(query_response, { "q" => "dogs" })

      expect(presenter.topic_options).to eql([
        "Business and economy",
        "Crime and justice",
        "Environment",
        "Mapping",
        "Society",
        "Towns and cities",
      ])
    end
  end

  describe "#format_options" do
    it "returns a full list if no query is specified" do
      query_response = { "responseHeader" => {
        "status" => 0,
        "params" => { "q" => "*:*", "wt" => "json" },
      } }
      presenter = described_class.new(query_response, {})

      expect(presenter.format_options).to eql(Search::Solr::FORMAT_MAPPINGS.keys)
    end

    it "returns only datafiles' formats included in returned datasets" do
      query_response =
        { "responseHeader" => {
            "params" => { "q" => "title:\"dogs\" OR notes:\"dogs\" AND NOT site_id:dgu_organisations" },
          },
          "facet_counts" => {
            "facet_fields" => {
              "res_format" => ["CSV", 10, "GEOJSON", 5, "csv.", 2, ".html"],
            },
          } }

      presenter = described_class.new(query_response, { "q" => "dogs" })

      expect(presenter.format_options).to eql(%w[
        CSV
        GEOJSON
        HTML
      ])
    end
  end
end
