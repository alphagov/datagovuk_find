require "rails_helper"

RSpec.describe Dgu::CollectionsService, type: :service do
  let(:collections_config) do
    {
      "nested-collection" => [
        {
          slug: "first-page",
          title: "First page",
        },
        {
          slug: "second-page",
          title: "Second page",
        },
      ],
    }.with_indifferent_access
  end
  let(:collection) { "nested-collection" }
  let(:page) { "first-page" }
  let(:first_page) { "first-page" }
  let(:last_page) { "second-page" }

  before do
    allow(YAML).to receive(:load_file).with(Rails.root.join("config/collections.yml")).and_return(collections_config)
    allow(Rails.configuration.x).to receive(:collection_pages).and_return(collections_config)
    allow(Rails.configuration.x).to receive(:generated_collections_location).and_return("tmp/collections")
    allow(File).to receive(:file?).and_return(true)
  end

  describe "#initialize" do
    it "sets the collection and page_name attributes" do
      service = Dgu::CollectionsService.new(collection, page)

      expect(service.collection).to eq(collection)
      expect(service.page_name).to eq(page)
    end
  end

  describe "#valid_collection_page?" do
    context "when collection and page are valid" do
      it "returns true" do
        service = Dgu::CollectionsService.new(collection, page)
        expect(service.valid_collection_page?).to be true
      end
    end

    context "when page is invalid" do
      it "returns false" do
        service = Dgu::CollectionsService.new(collection, "invalid-page")
        expect(service.valid_collection_page?).to be false
      end
    end

    context "when page is nil" do
      it "returns true" do
        service = Dgu::CollectionsService.new(collection, nil)
        expect(service.valid_collection_page?).to be true
      end
    end

    context "when page is blank" do
      it "returns true" do
        service = Dgu::CollectionsService.new(collection, "")
        expect(service.valid_collection_page?).to be true
      end
    end
  end

  describe "#collections_slugs" do
    it "returns the collection slugs" do
      service = Dgu::CollectionsService.new(collection)

      expect(service.collections_slugs).to include(
        have_attributes(
          slug: collection,
          title: "Nested collection",
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

  describe "#priority_page" do
    it "returns the priority page path for the collection" do
      service = Dgu::CollectionsService.new(collection)
      expect(service.priority_page).to eq("/collections/#{collection}/#{first_page}")
    end
  end

  describe "#image_path" do
    it "returns the image path for the collection" do
      service = Dgu::CollectionsService.new(collection)
      expect(service.image_path).to eq("/v2/collections/badge-#{collection}.png")
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
        title: "First page",
        slug: "first-page",
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
          slug: "second-page",
          title: "Second page",
          url: "/collections/nested-collection/second-page",
        },
      )
    end

    it "returns nil when on the last page" do
      service = Dgu::CollectionsService.new(collection, last_page)
      expect(service.next_page).to eq(nil)
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
          slug: "first-page",
          title: "First page",
          url: "/collections/nested-collection/first-page",
        },
      )
    end
  end
end
