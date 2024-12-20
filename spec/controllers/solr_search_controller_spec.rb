require "rails_helper"

RSpec.describe SolrSearchController, type: :controller do
  let(:valid_params) { { q: "test search", page: 1, sort: "asc" } }
  let(:solr_response_with_results) do
    {
      "response" => {
        "numFound" => 2,
        "docs" => [
          { "id" => "1", "title" => "Test Result 1" },
          { "id" => "2", "title" => "Test Result 2" },
        ],
      },
    }
  end
  let(:solr_response_no_results) do
    { "response" => { "numFound" => 0, "docs" => [] } }
  end

  describe "GET #search" do
    context "when there are search results" do
      before do
        allow(Search::Solr).to receive(:search).and_return(solr_response_with_results)
        get :search, params: valid_params
      end

      it "returns a successful response" do
        expect(response).to be_successful
      end

      it "sets sort" do
        expect(controller.instance_variable_get(:@sort)).to eq("asc")
      end

      it "sets number of results" do
        expect(controller.instance_variable_get(:@num_results)).to eq(2)
      end

      it "sets datasets" do
        datasets = controller.instance_variable_get(:@datasets)
        expect(datasets.size).to eq(2)
      end
    end

    context "when there are no search results" do
      before do
        allow(Search::Solr).to receive(:search).and_return(solr_response_no_results)
        get :search, params: valid_params
      end

      it "returns a successful response" do
        expect(response).to be_successful
      end

      it "sets number of results as 0" do
        expect(controller.instance_variable_get(:@num_results)).to eq(0)
      end

      it "sets datasets as an empty array" do
        expect(controller.instance_variable_get(:@datasets)).to be_empty
      end
    end

    context "when there is a Solr error (HTTP 400)" do
      before do
        mock_solr_http_error(status: 400)
        get :search, params: { q: "&&" }
      end

      it "returns a successful response" do
        expect(response).to be_successful
      end

      it "sets number of results as 0" do
        expect(controller.instance_variable_get(:@num_results)).to eq(0)
      end

      it "sets datasets as an empty array" do
        expect(controller.instance_variable_get(:@datasets)).to be_empty
      end
    end

    context "when query string is empty after processing" do
      before do
        allow(Search::Solr).to receive(:search).and_raise(Search::Solr::NoSearchTermsError)
        get :search, params: { q: "the" }
      end

      it "returns a successful response" do
        expect(response).to be_successful
      end

      it "sets number of results as 0" do
        expect(controller.instance_variable_get(:@num_results)).to eq(0)
      end

      it "sets datasets as an empty array" do
        expect(controller.instance_variable_get(:@datasets)).to be_empty
      end
    end

    context "when there is an unexpected error" do
      it "raises an error for an unexpected Solr error" do
        mock_solr_http_error(status: 500)

        expect { get :search, params: valid_params }.to raise_error(StandardError)
      end

      it "raises an error for an unexpected error" do
        allow(Search::Solr).to receive(:search).and_raise(StandardError)

        expect { get :search, params: valid_params }.to raise_error(StandardError)
      end
    end
  end
end
