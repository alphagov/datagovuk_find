require "rails_helper"

RSpec.describe "rack-attack throttling", type: :request do
  include Rack::Test::Methods
  include ActiveSupport::Testing::TimeHelpers

  delegate :application, to: :Rails

  let(:solr_response_no_results) do
    { "response" => { "numFound" => 0, "docs" => [] } }
  end
  let(:valid_params) { { q: "test search", page: 1, sort: "asc" } }
  let(:filestore_path) { Rails.root.join("tmp/cache/rack_attack_test") }
  let!(:original_cache_store) { Rails.cache }

  describe "GET /search" do
    let(:path) { "/search" }
    let(:headers) { { "REMOTE_ADDR" => "1.2.3.4" } }

    before do
      FileUtils.rm_f(filestore_path)
      FileUtils.mkdir_p(filestore_path)
      Rails.cache = ActiveSupport::Cache::FileStore.new(filestore_path)
      Rack::Attack.cache.store = Rails.cache
      Rails.cache.clear
      allow_any_instance_of(RSolr::Client).to receive(:get).and_return(solr_response_no_results)
      allow(Rack::Attack).to receive(:enabled).and_return(true)
      allow(Search::Solr).to receive(:search).and_return(solr_response_no_results)
    end

    after do
      FileUtils.rm_f(filestore_path)
      Rails.cache = original_cache_store
    end

    context "when requests are within the rate limit" do
      it "returns a success" do
        get path, valid_params, headers
        expect(last_response.status).to eq(200)
      end
    end

    context "when requests exceeded the rate limit" do
      it "returns http status 429" do
        get path, valid_params, headers
        expect(last_response.status).to eq(200)

        get path, valid_params, headers
        expect(last_response.status).to eq(429)

        get path, valid_params, headers
        expect(last_response.status).to eq(429)
      end
    end

    context "when there are no values in the rate env variables" do
      it "does not return a failure http response" do
        allow(ENV).to receive(:fetch).with("RATE_LIMIT_COUNT", nil).and_return("")
        allow(ENV).to receive(:fetch).with("RATE_LIMIT_PERIOD", nil).and_return("")

        get path, valid_params, headers
        expect(last_response.status).to eq(200)
      end
    end

    context "when period exceeded" do
      it "allows a new request after the throttle period passes" do
        get path, valid_params, headers
        expect(last_response.status).to eq(200)

        get path, valid_params, headers
        expect(last_response.status).to eq(429)

        travel_to(Time.current + 60) do
          get path, valid_params, headers
          expect(last_response.status).to eq(200)
        end
      end
    end
  end
end
