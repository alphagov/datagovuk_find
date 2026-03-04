require "rails_helper"

RSpec.describe CollectionsService, type: :service do
  before do
    allow(Rails.configuration.x).to receive(:generated_collections_location).and_return("app/views/generated/collections")
  end

  let(:collection) { "business-and-economy" }
  let(:page) { "get-charity-information" }
  let(:first_page) { "agricultural-commodity-prices" }

  describe "#initialize" do
    it "sets the collection and page_name attributes" do
      service = CollectionsService.new(collection, page)

      expect(service.collection).to eq(collection)
      expect(service.page_name).to eq(page)
    end
  end

  describe "#collections_slugs" do
    it "returns the collection slugs" do
      service = CollectionsService.new(collection)

      expect(service.collections_slugs).to include(
        have_attributes(
          slug: collection,
          title: "Business and economy",
        ),
      )
    end
  end

  describe "#view_template" do
    it "returns the view template path for the collection" do
      service = CollectionsService.new(collection)
      expect(service.view_template_path).to eq("generated/collections/#{collection}/#{first_page}")
    end
  end

  describe "#valid_collection_page?" do
    context "when both collection and page exist" do
      it "returns true" do
        service = CollectionsService.new(collection, page)
        expect(service.valid_collection_page?).to be true
      end
    end

    context "when only collection exists and page is nil" do
      it "returns true" do
        service = CollectionsService.new(collection)
        expect(service.valid_collection_page?).to be true
      end
    end

    context "when only collection exists and page is blank" do
      it "returns true" do
        service = CollectionsService.new(collection, "")
        expect(service.valid_collection_page?).to be true
      end
    end

    context "when collection does not exist" do
      it "returns false" do
        service = CollectionsService.new("non-existing-collection", page)
        expect(service.valid_collection_page?).to be false
      end
    end

    context "when page does not exist" do
      it "returns false" do
        service = CollectionsService.new(collection, "non-existing-page")

        expect(service.valid_collection_page?).to be false
      end
    end
  end

  describe "#collection_pages" do
    it "returns side navigations for a collection" do
      service = CollectionsService.new(collection)

      expect(service.collection_pages).to include({
        url: "/collections/#{collection}/#{page}",
        title: "Get charity information",
        selected: false,
      })
    end
  end

  describe "#page" do
    context "when page is provided" do
      it "returns page" do
        service = CollectionsService.new(collection, page)

        expect(service.page).to eq(page)
      end
    end

    context "when page is not provided" do
      it "returns the first page" do
        service = CollectionsService.new(collection)

        expect(service.page).to eq(first_page)
      end
    end
  end
end
