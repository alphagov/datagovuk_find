require "rails_helper"

RSpec.describe "v2/pages", type: :request do
  describe "#home" do
    before do
      get root_path
    end

    it "returns success response" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the home page" do
      expect(response.body).to include("Test home")
    end
  end
end
