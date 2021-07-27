require "rails_helper"

RSpec.describe PreviewsHelper do
  describe "#numeric?" do
    it "returns true when given an integer as a string" do
      expect(helper.numeric?("123")).to be true
    end

    it "returns true when given a negative number" do
      expect(helper.numeric?("-123")).to be true
    end

    it "returns true when given a number with a decimal" do
      expect(helper.numeric?("123.45")).to be true
    end

    it "returns true when given a number prefixed with a decimal point" do
      expect(helper.numeric?(".45")).to be true
    end

    it "returns false when given text" do
      expect(helper.numeric?("some text with 1 number")).to be false
    end

    it "returns false when given number in a formatted presentation" do
      expect(helper.numeric?("020 123 12345")).to be false
    end

    it "returns false when given a number with multiple decimal points" do
      expect(helper.numeric?("100.34.45")).to be false
    end

    it "returns false when given a non-string object" do
      expect(helper.numeric?(nil)).to be false
    end
  end
end
