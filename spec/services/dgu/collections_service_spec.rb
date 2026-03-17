require "rails_helper"

RSpec.describe Dgu::CollectionsService, type: :service do
  before do
    allow(Rails.configuration.x).to receive(:generated_collections_location).and_return("app/views/generated/collections")
  end

  let(:collection) { "business-and-economy" }
  let(:page) { "get-charity-information" }
  let(:first_page) { "get-company-information" }
  let(:last_page) { "inflation" }

  describe "#initialize" do
    it "sets the collection and page_name attributes" do
      service = Dgu::CollectionsService.new(collection, page)

      expect(service.collection).to eq(collection)
      expect(service.page_name).to eq(page)
    end
  end

  describe "collections config" do
    it "sets the collection_pages attribute to a valid value" do
      markdown_collection_location = "app/content/collections"
      collection_pages = Rails.configuration.x.collection_pages
      collection_pages.each do |collection, collection_items|
        collection_items.each do |collection_item|
          expected_markdown_file = Rails.root.join(markdown_collection_location, collection, "#{collection_item[:slug]}.md")
          expect(File.file?(expected_markdown_file)).to eq(true), "Missing markdown file #{expected_markdown_file} which was present in collections_pages config"
        end
      end
    end
  end

  describe "#collections_slugs" do
    it "returns the collection slugs" do
      service = Dgu::CollectionsService.new(collection)

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
      service = Dgu::CollectionsService.new(collection, first_page)
      expect(service.view_template_path).to eq("generated/collections/#{collection}/#{first_page}")
    end
  end

  describe "#valid_collection_page?" do
    context "when both collection and page exist" do
      it "returns true" do
        service = Dgu::CollectionsService.new(collection, page)
        expect(service.valid_collection_page?).to be true
      end
    end

    context "when only collection exists and page is nil" do
      it "returns true" do
        service = Dgu::CollectionsService.new(collection)
        expect(service.valid_collection_page?).to be true
      end
    end

    context "when only collection exists and page is blank" do
      it "returns true" do
        service = Dgu::CollectionsService.new(collection, "")
        expect(service.valid_collection_page?).to be true
      end
    end

    context "when collection does not exist" do
      it "returns false" do
        expect { Dgu::CollectionsService.new("non-existing-collection", page) }.to raise_error(Dgu::CollectionNotFound)
      end
    end

    context "when page does not exist" do
      it "returns false" do
        service = Dgu::CollectionsService.new(collection, "non-existing-page")

        expect(service.valid_collection_page?).to be false
      end
    end
  end

  describe "#collection_pages" do
    it "returns side navigations for a collection" do
      service = Dgu::CollectionsService.new(collection)

      expect(service.collection_pages).to include({
        url: "/collections/#{collection}/#{page}",
        title: "Get charity information",
        slug: "get-charity-information",
        selected: false,
      })
    end
  end

  describe "#page" do
    context "when page is provided" do
      it "returns page" do
        service = Dgu::CollectionsService.new(collection, page)

        expect(service.page).to eq(page)
      end
    end
  end

  describe "#next_page" do
    it "returns the next page when on the first page" do
      service = Dgu::CollectionsService.new(collection, first_page)
      expect(service.next_page).to eq(
        {
          selected: false,
          slug: "get-charity-information",
          title: "Get charity information",
          url: "/collections/business-and-economy/get-charity-information",
        },
      )
    end

    it "returns the first page when on the last page" do
      service = Dgu::CollectionsService.new(collection, last_page)
      expect(service.next_page).to eq(
        {
          selected: false,
          slug: "get-company-information",
          title: "Get company information",
          url: "/collections/business-and-economy/get-company-information",
        },
      )
    end
  end

  describe "#previous_page" do
    it "returns nil when on the first page" do
      service = Dgu::CollectionsService.new(collection, first_page)
      expect(service.previous_page).to eq(nil)
    end

    it "returns the previous page when on the last page" do
      service = Dgu::CollectionsService.new(collection, last_page)
      expect(service.previous_page).to eq(
        {
          selected: false,
          slug: "bank-of-england-interest-rates",
          title: "Bank of England interest rates",
          url: "/collections/business-and-economy/bank-of-england-interest-rates",
        },
      )
    end
  end
end
