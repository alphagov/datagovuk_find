require "rails_helper"

RSpec.describe SearchController, type: :controller do
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

    context "when the query has Welsh letters" do
      let(:welsh_characters) { "âêîôûŵŷäëïöüẅÿáéíóúẃýàèìòùẁỳ" }

      it "returns a successful response" do
        allow(Search::Solr).to receive(:search).and_return(solr_response_no_results)
        get :search, params: { q: welsh_characters, page: 1, sort: "asc" }

        expect(response).to be_successful
      end
    end

    context "when the query has special characters" do
      it "returns a successful response" do
        allow(Search::Solr).to receive(:search).and_return(solr_response_no_results)
        get :search, params: { q: "!@£$%^&*()-_=+\"'|\\`~/?,><.", page: 1, sort: "asc" }

        expect(response).to be_successful
      end
    end

    context "when the query is empty" do
      it "returns a successful response" do
        allow(Search::Solr).to receive(:search).and_return(solr_response_no_results)
        get :search, params: { q: "", page: 1, sort: "asc" }

        expect(response).to be_successful
      end
    end

    context "when the query has invalid characters mixed in with valid characters" do
      let(:invalid_queryies) { ["testБ", "Б^lklkj", "^%&ش"] }
      it "redirects to the home page" do
        allow(Search::Solr).to receive(:search).and_return(solr_response_no_results)

        invalid_queryies.each do |invalid_query|
          get :search, params: { q: invalid_query, page: 1, sort: "asc" }

          expect(response).to redirect_to root_path
        end
      end
    end

    context "when the query has non English/Welsh letters" do
      let(:non_latin_characters) { %w[Б 好 ش] }
      it "redirects to the home page" do
        allow(Search::Solr).to receive(:search).and_return(solr_response_no_results)

        non_latin_characters.each do |non_latin_char|
          get :search, params: { q: non_latin_char, page: 1, sort: "asc" }

          expect(response).to redirect_to root_path
        end
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
