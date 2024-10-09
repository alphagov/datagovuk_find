require "rails_helper"

RSpec.describe SolrDatasetsController, type: :controller do
  render_views
  let(:results) { JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_dataset.json").to_s)) }
  let(:params) { results["response"]["docs"].first }
  let(:dataset) { SolrDataset.new(params) }

  before do
    allow(Search::Solr).to receive(:get_by_uuid).and_return(results)
  end

  describe "Breadcrumb" do
    context "Visiting search results from within the application" do
      it "will not display the publisher name if the referrer host name is the application host name" do
        request.env["HTTP_REFERER"] = "http://test.host/search/solr?q=fancypants"
        get :show, params: { uuid: dataset.id, name: dataset.name }

        expect(response.body).to have_css("div.breadcrumbs")
        expect(response.body).to_not have_css("li", text: "Ministry of Housing, Communities and Local Government")
        expect(response.body).to have_css("li", text: "Search")
      end
    end

    context "Visiting search results from outside the application" do
      it "will display the publisher name if the user has visited the search page from outside the application" do
        request.env["HTTP_REFERER"] = "http://unknown.host/search/solr?q=fancypants"
        get :show, params: { uuid: dataset.id, name: dataset.name }

        expect(response.body).to have_css("div.breadcrumbs")
        expect(response.body).to have_css("li", text: "Ministry of Housing, Communities and Local Government")
        expect(response.body).to_not have_css("li", text: "Search")
      end
    end
  end

  describe "visiting the dataset page with an outdated slug" do
    it "redirects to the latest slugged URL" do
      get :show, params: { uuid: dataset.id, name: "outdated-slug" }
      expect(response).to redirect_to(solr_dataset_url(dataset.id, dataset.name))
    end
  end
end
