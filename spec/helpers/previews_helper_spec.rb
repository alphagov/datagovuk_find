require "rails_helper"

RSpec.describe PreviewsHelper do
  describe "#is_numeric" do
    it "returns true when given an integer as a string" do
      expect(helper.is_numeric("123")).to be true
    end

    it "returns false when given a text string" do
      expect(helper.is_numeric("some text")).to be false
    end

    it "returns false when given a non-string object" do
      expect(helper.is_numeric(nil)).to be false
    end
  end
end
