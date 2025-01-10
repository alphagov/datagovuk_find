# spec/models/organisation_spec.rb

require "rails_helper"

RSpec.describe Organisation do
  describe "#initialize" do
    context "when organisation is returned from Solr" do
      let(:slug) { "test-org" }
      let(:valid_hash) do
        {
          "title" => "Test Organisation",
          "name" => slug,
          "extras_contact-email" => "contact@example.com",
          "extras_contact-name" => "John Doe",
          "extras_foi-email" => "foi@example.com",
          "extras_foi-web" => "http://foi.example.com",
          "extras_foi-name" => "Jane Doe",
        }
      end

      it "assigns the correct attributes from the hash" do
        organisation = described_class.new(valid_hash, slug)

        expect(organisation.title).to eq("Test Organisation")
        expect(organisation.name).to eq("test-org")
        expect(organisation.contact_email).to eq("contact@example.com")
        expect(organisation.contact_name).to eq("John Doe")
        expect(organisation.foi_email).to eq("foi@example.com")
        expect(organisation.foi_web).to eq("http://foi.example.com")
        expect(organisation.foi_name).to eq("Jane Doe")
      end
    end

    context "when organisation doeasn't exist in Solr" do
      let(:slug) { "test-org" }

      it "uses the slug to set the title and name" do
        organisation = described_class.new(nil, slug)

        expect(organisation.title).to eq("Test Org")
        expect(organisation.name).to eq("test-org")
      end

      it "doesn't set contact and FOI details" do
        organisation = described_class.new(nil, slug)

        expect(organisation.contact_email).to eq(nil)
        expect(organisation.contact_name).to eq(nil)
        expect(organisation.foi_email).to eq(nil)
        expect(organisation.foi_web).to eq(nil)
        expect(organisation.foi_name).to eq(nil)
      end

      it "calls capture_exception_in_sentry" do
        allow_any_instance_of(described_class).to receive(:capture_exception_in_sentry)

        expect(described_class.new(nil, slug)).to have_received(:capture_exception_in_sentry).with(slug)
      end
    end
  end
end
