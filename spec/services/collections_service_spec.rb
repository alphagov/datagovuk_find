require "rails_helper"

RSpec.describe CollectionsService, type: :service do
  before do
    allow(Rails.configuration.x).to receive(:generated_collections_location).and_return("app/views/generated/collections")
  end

  let(:collection) { "business-and-economy" }
  let(:topic) { "get-charity-information" }
  let(:first_topic) { "food-hygiene-ratings" }

  describe "#initialize" do
    it "sets the collection and topic_name attributes" do
      service = CollectionsService.new(collection, topic)

      expect(service.collection).to eq(collection)
      expect(service.topic_name).to eq(topic)
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

  describe "#valid_collection_topic?" do
    context "when both collection and topic exist" do
      it "returns true" do
        service = CollectionsService.new(collection, topic)
        expect(service.valid_collection_topic?).to be true
      end
    end

    context "when only collection exists and topic is nil" do
      it "returns true" do
        service = CollectionsService.new(collection)
        expect(service.valid_collection_topic?).to be true
      end
    end

    context "when only collection exists and topic is blank" do
      it "returns true" do
        service = CollectionsService.new(collection, "")
        expect(service.valid_collection_topic?).to be true
      end
    end

    context "when collection does not exist" do
      it "returns false" do
        service = CollectionsService.new("non-existing-collection", topic)
        expect(service.valid_collection_topic?).to be false
      end
    end

    context "when topic does not exist" do
      it "returns false" do
        service = CollectionsService.new(collection, "non-existing-topic")

        expect(service.valid_collection_topic?).to be false
      end
    end
  end

  describe "#side_navigations" do
    it "returns side navigations for a collection" do
      service = CollectionsService.new(collection)

      expect(service.side_navigations).to include(topic)
    end
  end

  describe "#topic" do
    context "when topic is provided" do
      it "returns topic" do
        service = CollectionsService.new(collection, topic)

        expect(service.topic).to eq(topic)
      end
    end

    context "when topic is not provided" do
      it "returns the first topic" do
        service = CollectionsService.new(collection)

        expect(service.topic).to eq(first_topic)
      end
    end
  end
end
