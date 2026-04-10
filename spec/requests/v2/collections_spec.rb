require "rails_helper"

RSpec.describe "Collections", type: :request do
  let(:collections_config) do
    {
      "test-collection" => [
        {
          slug: "test-collection",
          title: "Test title",
        },
      ],
    }.with_indifferent_access
  end

  let(:service) do
    instance_double(Dgu::CollectionsService,
                    valid_collection_page?: true,
                    collection: "test-collection",
                    collection_pages: [
                      { slug: "test-collection", title: "Test title", url: "/collections/test-collection/test-collection", selected: true },
                    ],
                    page: "test-collection",
                    view_template_path: "v2/collection/_content",
                    image_path: "/v2/collections/badge-test-collection.png",
                    next_page: nil,
                    previous_page: nil,
                    title: "Test title")
  end

  let(:redirect_service_double) do
    instance_double(Dgu::CollectionsService,
                    priority_page: "/collections/test-collection/test-collection")
  end

  before do
    allow(YAML).to receive(:load_file).with(Rails.root.join("config/collections.yml")).and_return(collections_config)
    allow(Dgu::CollectionsService).to receive(:new).and_raise(Dgu::CollectionNotFound)
    allow(Dgu::CollectionsService).to receive(:new).with("test-collection", "test-collection").and_return(service)
    allow(Dgu::CollectionsService).to receive(:new).with("test-collection", nil).and_return(redirect_service_double)
  end

  context "visiting a collection topic path" do
    let(:collection_path) { "/collections/test-collection/test-collection" }

    it "returns success response" do
      get collection_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("<title>Test title - Collection - data.gov.uk</title>")
    end

    it "shows the collection title" do
      get collection_path

      expect(response.body).to include("Test title")
    end
  end

  context "visiting an invalid topic path" do
    it "returns 404 response" do
      get "/collections/test-collection/invalid-page"
      expect(response).to have_http_status(:not_found)
    end
  end

  context "visiting a collection root path" do
    let(:collection_root_path) { "/collections/test-collection" }
    it "returns redirect response" do
      get collection_root_path

      expect(response).to redirect_to("/collections/test-collection/test-collection")
    end

    it "invalid path shows 404" do
      get "/collections/invalid-collection"

      expect(response).to have_http_status(:not_found)
    end
  end
end
