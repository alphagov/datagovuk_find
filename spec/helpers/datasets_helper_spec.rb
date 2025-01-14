require "rails_helper"

RSpec.describe DatasetsHelper do
  describe "to_markdown" do
    it "returns 'Not provided' if the input is nil" do
      expect(helper.to_markdown(nil)).to eq("Not provided")
    end
  end

  describe "#contact_email_is_email?" do
    it "returns true when email string is 'valid' (contains '@')" do
      dataset = instance_double(SolrDataset, contact_email: "foo@bar.com")
      expect(helper.contact_email_is_email?(dataset)).to be_truthy
    end

    it "returns false when the email is invalid" do
      dataset = instance_double(SolrDataset, contact_email: "http://foo.com")
      expect(helper.contact_email_is_email?(dataset)).to be_falsey
    end
  end

  describe "#foi_email_is_email?" do
    it "returns true when email string is 'valid' (contains '@')" do
      dataset = instance_double(SolrDataset, foi_email: "foo@bar.com")
      expect(helper.foi_email_is_email?(dataset)).to be_truthy
    end

    it "returns false when the email is invalid" do
      dataset = instance_double(SolrDataset, foi_email: "http://foo.com")
      expect(helper.foi_email_is_email?(dataset)).to be_falsey
    end
  end
end
