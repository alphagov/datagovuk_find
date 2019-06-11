require 'rails_helper'
require 'securerandom'

RSpec.describe 'CKAN redirection', type: :request do
  let(:path) { nil }

  shared_examples "does redirect to CKAN" do
    it "does redirect to CKAN" do
      get path

      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("http://testdomain#{path}")
    end
  end

  shared_examples "doesn't redirect to CKAN" do
    it "doesn't redirect to CKAN" do
      get path

      expect(response).to_not have_http_status(:moved_permanently)
    end
  end

  context "with a known path" do
    let(:path) { "/dataset/#{SecureRandom.uuid}" }
    include_examples "doesn't redirect to CKAN"
  end

  context "with an assets path" do
    let(:path) { "/find-assets/application-#{SecureRandom.uuid}.js" }
    include_examples "doesn't redirect to CKAN"
  end

  context "with an unknown path" do
    let(:path) { "/an/unknown/path" }
    include_examples "does redirect to CKAN"
  end

  context "with an unknown path that includes 'find-assets'" do
    let(:path) { "/an/unknown/path/find-assets/application" }
    include_examples "does redirect to CKAN"
  end
end
