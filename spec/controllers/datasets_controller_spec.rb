require "rails_helper"

RSpec.describe DatasetsController, type: :controller do
  render_views
  let(:results) { JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_dataset.json").to_s)) }
  let(:dataset) { SolrDataset.new(results["response"]["docs"].first) }
  let(:org_response) { JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_organisation.json").to_s)) }
  let(:organisation) { org_response["response"]["docs"].first }

  before do
    allow(Search::Solr).to receive(:get_organisation).and_return(org_response)
    allow(SolrDataset).to receive(:get_by_uuid).and_return(dataset)
  end

  describe "Breadcrumb" do
    context "Visiting search results from within the application" do
      it "will not display the publisher name if the referrer host name is the application host name" do
        request.env["HTTP_REFERER"] = "http://test.host/search?q=fancypants"
        get :show, params: { uuid: dataset.uuid, name: dataset.name }

        expect(response.body).to have_css("div.breadcrumbs")
        expect(response.body).to_not have_css("li", text: "Ministry of Housing, Communities and Local Government")
        expect(response.body).to have_css("li", text: "Search")
      end
    end

    context "Visiting search results from outside the application" do
      it "will display the publisher name if the user has visited the search page from outside the application" do
        request.env["HTTP_REFERER"] = "http://unknown.host/search?q=fancypants"
        get :show, params: { uuid: dataset.uuid, name: dataset.name }

        expect(response.body).to have_css("div.breadcrumbs")
        expect(response.body).to have_css("li", text: "Ministry of Housing, Communities and Local Government")
        expect(response.body).to_not have_css("li", text: "Search")
      end
    end
  end

  describe "visiting the dataset page with an outdated slug" do
    it "redirects to the latest slugged URL" do
      get :show, params: { uuid: dataset.uuid, name: "outdated-slug" }
      expect(response).to redirect_to(dataset_url(dataset.uuid, dataset.name))
    end
  end

  describe "visiting the dataset page from search results" do
    it "links back to the search results page with the same query parameters" do
      query_params = "q=&filters%5Bpublisher%5D=Ministry%20of%20Housing%2C%20Communities%20and%20Local%20Government&filters%5Btopic%5D=&filters%5Bformat%5D=CSV&sort=best"
      request.env["HTTP_REFERER"] = "http://test.host/search?#{query_params}"
      get :show, params: { uuid: dataset.uuid, name: dataset.name }

      expect(response.body).to have_css("div.breadcrumbs")
      expect(response.body).to have_css("li", text: "Search")
      expect(response.body).to have_link("Search", href: "/search?#{query_params}")
    end
  end
end
