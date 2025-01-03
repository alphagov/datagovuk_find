require "rails_helper"

RSpec.describe SolrDatafile do
  describe "#name" do
    it "returns the name" do
      datafile = described_class.new(
        { "name" => "Datafile name" }, nil
      )
      expect(datafile.name).to eq("Datafile name")
    end

    it "returns description if name is nil" do
      datafile =
        described_class.new(
          { "description" => "Datafile description" },
          nil,
        )
      expect(datafile.name).to eq("Datafile description")
    end

    it "returns description if name is an empty string" do
      datafile = described_class.new(
        { "name" => "",
          "description" => "Datafile description" },
        nil,
      )
      expect(datafile.name).to eq("Datafile description")
    end
  end

  describe "#csv?" do
    it "returns true if datafile's format is capitalised" do
      datafile = build(:solr_datafile, format: "CSV ")
      expect(datafile.csv?).to be true
    end

    it "returns true if datafile's format is CSV with a tailing whitespace" do
      datafile = build(:solr_datafile, format: "CSV ")
      expect(datafile.csv?).to be true
    end

    it "returns true if datafile's format is downcase" do
      datafile = build(:solr_datafile, format: "csv")
      expect(datafile.csv?).to be true
    end

    it "returns true if datafile's format has leading fullstop" do
      datafile = build(:solr_datafile, format: ".csv")
      expect(datafile.csv?).to be true
    end

    it "returns false if datafile's format not CSV" do
      datafile = build(:solr_datafile, format: "HTML")
      expect(datafile.csv?).to be false
    end
  end
end
