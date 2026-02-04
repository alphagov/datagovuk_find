require "rails_helper"

RSpec.describe CollectionsService, type: :service do
  before do
    allow(Rails.configuration.x).to receive(:generated_collections_location).and_return("app/views/generated/collections")
  end

  let(:collection) { "business-and-economy" }
  let(:topic) { "get-charity-information" }
  let(:first_topic) { "food-hygiene-ratings" }

  describe "#initialize" do
    it "sets the collection_name and topic_name attributes" do
      service = CollectionsService.new(collection, topic)

      expect(service.collection_name).to eq(collection)
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

  describe "#collection_topic?" do
    context "when both collection and topic exist" do
      it "returns true" do
        service = CollectionsService.new(collection, topic)
        expect(service.collection_topic?(collection, topic)).to be true
      end
    end

    context "when only collection exists and topic is nil" do
      it "returns true" do
        service = CollectionsService.new(collection)
        expect(service.collection_topic?(collection, nil)).to be true
      end
    end

    context "when only collection exists and topic is blank" do
      it "returns true" do
        service = CollectionsService.new(collection, "")
        expect(service.collection_topic?(collection, "")).to be true
      end
    end

    context "when collection does not exist" do
      it "returns false" do
        service = CollectionsService.new("non-existing-collection", topic)
        expect(service.collection_topic?("non-existing-collection", topic)).to be false
      end
    end

    context "when topic does not exist" do
      it "returns false" do
        service = CollectionsService.new(collection, "non-existing-topic")

        expect(service.collection_topic?(collection, "non-existing-topic")).to be false
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

  describe "#topics" do
    it "returns all topics for a collection" do
      service = CollectionsService.new(collection)

      expect(service.topics).to include("get-charity-information.html.erb", "get-company-information.html.erb", "food-hygiene-ratings.html.erb")
    end
  end

  describe "#collection?" do
    it "returns true for existing collection" do
      service = CollectionsService.new(collection)

      expect(service.collection?(collection)).to be true
    end
    context "collection does not exist" do
      it "returns false for non-existing collection" do
        service = CollectionsService.new("non-existing-collection")

        expect(service.collection?("non-existing-collection")).to be false
      end
    end
  end

  describe "#topic?" do
    it "returns true" do
      service = CollectionsService.new(collection)

      expect(service.topic?("get-company-information")).to be true
    end

    context "topic does not exist" do
      it "returns false" do
        service = CollectionsService.new(collection)

        expect(service.topic?("non-existing-topic")).to be false
      end
    end

    context "when topic is blank" do
      it "returns true" do
        service = CollectionsService.new(collection)
        expect(service.topic?("")).to be true
      end
    end

    context "when topic is nil" do
      it "returns true" do
        service = CollectionsService.new("no_topics")

        expect(service.topic?(nil)).to be true
      end
    end
  end

  describe "#first_topic" do
    it "returns first topic of the collection" do
      service = CollectionsService.new(collection)

      expect(service.first_topic).to eq(first_topic)
    end
  end
end
