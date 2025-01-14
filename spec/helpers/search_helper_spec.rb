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
end
