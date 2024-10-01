require "rails_helper"

RSpec.describe SolrDataset do
  describe "#initialize" do
    let(:dataset) do
      described_class.new(
        "title" => "A very interesting dataset",
        "metadata_modified" => "2024-10-01T16:09:41Z",
        "validated_data_dict" => "{ \"organization\": { \"title\": \"A county council\" }}",
        "notes" => "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
      )
    end

    it "sets the title correctly" do
      expect(dataset.title).to eq("A very interesting dataset")
    end

    it "sets the summary correctly" do
      expect(dataset.summary).to eq("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
    end

    it "sets the public_updated_at correctly" do
      expect(dataset.public_updated_at).to eq("2024-10-01T16:09:41Z")
    end

    it "sets the organisation name correctly" do
      expect(dataset.organisation).to eq("A county council")
    end
  end
end
