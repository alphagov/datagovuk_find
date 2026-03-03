require "rails_helper"

RSpec.describe "Posts", type: :request do
  describe "GET /data-manual/:slug" do
    context "when the markdown content exists" do
      it "returns a 200 status code" do
        get "/data-manual/who-this-manual-is-for"
        expect(response).to have_http_status(:ok)
      end
    end

    context "when the markdown content does not exist" do
      it "returns a 404 status code" do
        get "/data-manual/non-existent-slug"
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
