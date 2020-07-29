require "rails_helper"

RSpec.describe DatasetsController, type: :controller do
  render_views

  let(:dataset) { build :dataset }

  before do
    index(dataset)
  end

  describe "Breadcrumb" do
    context "Visiting search results from within the application" do
      it "will not display the publisher name if the referrer host name is the application host name" do
        request.env["HTTP_REFERER"] = "http://test.host/search?q=fancypants"
        get :show, params: { uuid: dataset.uuid, name: dataset.name }

        expect(response.body).to have_css("#dgu-breadcrumb")
        expect(response.body).to_not have_css("li", text: "Ministry of Defence")
        expect(response.body).to have_css("li", text: "Search")
      end
    end

    context "Visiting search results from outside the application" do
      it "will display the publisher name if the user has visited the search page from outside the application" do
        request.env["HTTP_REFERER"] = "http://unknown.host/search?q=fancypants"
        get :show, params: { uuid: dataset.uuid, name: dataset.name }

        expect(response.body).to have_css("#dgu-breadcrumb")
        expect(response.body).to have_css("li", text: "Ministry of Defence")
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
end
