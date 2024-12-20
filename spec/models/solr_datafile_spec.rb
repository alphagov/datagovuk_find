require "rails_helper"

RSpec.describe SolrDatafile do
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
