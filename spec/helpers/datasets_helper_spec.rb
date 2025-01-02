require "rails_helper"

RSpec.describe DatasetsHelper do
  describe "#sort_by_created_at" do
    let(:datafile1) { build :datafile, created_at: 1.hour.ago.iso8601 }
    let(:datafile2) { build :datafile, created_at: 2.hours.ago.iso8601 }

    it "orders datafiles lexicographically by created_at" do
      results = helper.sort_by_created_at([datafile2, datafile1])
      expect(results).to eq [datafile1, datafile2]
    end
  end

  describe "to_markdown" do
    it "returns 'Not provided' if the input is nil" do
      expect(helper.to_markdown(nil)).to eq("Not provided")
    end
  end

  describe "#contact_email_is_email?" do
    it "returns true when email string is 'valid' (contains '@')" do
      dataset = build :dataset, contact_email: "foo@bar.com"
      expect(helper.contact_email_is_email?(dataset)).to be_truthy
    end

    it "returns false when the email is invalid" do
      dataset = build :dataset, contact_email: "http://foo.com"
      expect(helper.contact_email_is_email?(dataset)).to be_falsey
    end
  end

  describe "#foi_email_is_email?" do
    it "returns true when email string is 'valid' (contains '@')" do
      dataset = build :dataset, foi_email: "foo@bar.com"
      expect(helper.foi_email_is_email?(dataset)).to be_truthy
    end

    it "returns false when the email is invalid" do
      dataset = build :dataset, foi_email: "http://foo.com"
      expect(helper.foi_email_is_email?(dataset)).to be_falsey
    end
  end
end
