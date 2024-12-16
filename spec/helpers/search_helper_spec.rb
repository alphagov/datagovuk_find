require "rails_helper"

RSpec.describe SearchHelper do
  describe "#process_query" do
    it "removes stop words from terms but keeps phrases intact" do
      query_params = '"quick brown" fox jumps over "lazy dog" in the forest'
      expected_result = '"quick brown" fox jumps "lazy dog" forest'

      result = SearchHelper.process_query(query_params)

      expect(result).to eq(expected_result)
    end

    it "handles input with only terms" do
      query_params = "fox jumps over the lazy dog"
      expected_result = "fox jumps lazy dog"

      result = SearchHelper.process_query(query_params)

      expect(result).to eq(expected_result)
    end

    it "handles input with only phrases" do
      query_params = '"quick brown" "lazy dog"'
      expected_result = '"quick brown" "lazy dog"'

      result = SearchHelper.process_query(query_params)

      expect(result).to eq(expected_result)
    end

    it "removes multiple stop words while preserving meaningful terms" do
      query_params = "a quick and simple test of the analyzer"
      expected_result = "quick simple test analyzer"

      result = SearchHelper.process_query(query_params)

      expect(result).to eq(expected_result)
    end

    it "handles empty input gracefully" do
      query_params = ""
      expected_result = ""

      result = SearchHelper.process_query(query_params)

      expect(result).to eq(expected_result)
    end
  end

  describe "#datafile_formats_for_select" do
    let(:dataset1) do
      build :dataset, datafiles: [build(:datafile, :raw, format: "foo"),
                                  build(:datafile, :raw, format: "")]
    end

    let(:dataset2) do
      build :dataset, datafiles: [build(:datafile, :raw, format: "baz"),
                                  build(:datafile, :raw, format: "baz")]
    end

    it "returns a sorted list of unique formats" do
      index(dataset1, dataset2)
      expect(datafile_formats_for_select).to eql %w[BAZ FOO]
    end
  end

  describe "#datafile_topics_for_select" do
    it "returns a sorted list of unique topics" do
      index(build(:dataset, topic: build(:topic, title: "foo")),
            build(:dataset, topic: build(:topic, title: "baz")),
            build(:dataset, topic: build(:topic, title: "baz")))

      expect(dataset_topics_for_select).to eql %w[baz foo]
    end
  end

  describe "#datafile_publishers_for_select" do
    it "returns a sorted list of unique publishers" do
      index(build(:dataset, organisation: build(:organisation, :raw, title: "foo")),
            build(:dataset, organisation: build(:organisation, :raw, title: "baz")),
            build(:dataset, organisation: build(:organisation, :raw, title: "baz")))

      expect(dataset_publishers_for_select).to eql %w[baz foo]
    end
  end
end
