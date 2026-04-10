require "rails_helper"

RSpec.describe Dgu::CollectionsService do
  let(:collection_slug) { "test-collection" }
  let(:page_slug) { "page-1" }
  let(:collections_path) { Pathname.new("/tmp/collections") }

  let(:mock_config_pages) do
    {
      "test-collection" => [
        { slug: "page-1", title: "Page One" },
        { slug: "page-2", title: "Page Two" },
      ],
      "another-collection" => [
        { slug: "page-1", title: "Page One" },
        { slug: "page-2", title: "Page Two" },
      ],
    }
  end

  before do
    allow(Rails.configuration.x).to receive(:generated_collections_location).and_return("spec/fixtures/collections")
    allow(Rails.configuration.x).to receive(:collection_pages).and_return(mock_config_pages)
  end

  describe "#initialize" do
    it "sets the collection" do
      service = described_class.new(collection_slug, page_slug)
      expect(service.collection).to eq(collection_slug)
    end

    it "sets the page name" do
      service = described_class.new(collection_slug, page_slug)
      expect(service.page_name).to eq(page_slug)
    end

    it "raises Dgu::CollectionNotFound if collection does not exist" do
      allow(Rails.root.join("collections/fake")).to receive(:exist?).and_return(false)
      expect {
        described_class.new("fake")
      }.to raise_error(Dgu::CollectionNotFound)
    end
  end

  describe "#next_page" do
    let(:service) { described_class.new(collection_slug, "page-1") }

    it "returns the next page in the sequence" do
      expect(service.next_page[:slug]).to eq("page-2")
    end

    it "returns nil if on the last page" do
      last_page_service = described_class.new(collection_slug, "page-2")
      expect(last_page_service.next_page).to be_nil
    end
  end

  describe "#previous_page" do
    let(:service) { described_class.new(collection_slug, "page-1") }

    it "returns the previous page" do
      second_page_service = described_class.new(collection_slug, "page-2")
      expect(second_page_service.previous_page[:slug]).to eq("page-1")
    end

    context "when on the first page" do
      let(:service) { described_class.new(collection_slug, "page-1") }

      it "returns nil if on the first page" do
        expect(service.previous_page).to be_nil
      end
    end
  end

  describe "#image_path" do
    it "returns the correct collection badge image path" do
      service = described_class.new(collection_slug)
      expect(service.image_path).to eq("v2/collections/badge-test-collection.png")
    end
  end

  describe "#view_template_path" do
    it "returns the correct view template path" do
      service = described_class.new(collection_slug, page_slug)
      expect(service.view_template_path).to eq("generated/collections/test-collection/page-1")
    end
  end

  describe "#priority_page" do
    it "returns the URL of the first page in the collection" do
      service = described_class.new(collection_slug)
      expect(service.priority_page).to eq("/collections/test-collection/page-1")
    end
  end
end
