require "rails_helper"

RSpec.feature "Solr Dataset page", type: :feature do
  let(:response) { JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_dataset.json").to_s)) }
  let(:params) { response["response"]["docs"].first }
  let(:dataset) { SolrDataset.new(params) }

  before do
    allow(Search::Solr).to receive(:get_by_uuid).and_return(response)
    visit solr_dataset_path(dataset.id, dataset.name)
  end

  feature "Meta information" do
    scenario "Meta title tag" do
      expect(page)
        .to have_css('meta[name="dc:title"][content="A very interesting dataset"]', visible: false)
    end

    scenario "Meta creator tag" do
      expect(page)
        .to have_css('meta[name="dc:creator"][content="Ministry of Housing, Communities and Local Government"]', visible: false)
    end

    scenario "Meta date tag" do
      expect(page)
        .to have_css('meta[name="dc:date"][content="2017-06-30"]', visible: false)
    end

    scenario "Meta licence tag" do
      expect(page)
        .to have_css('meta[name="dc:rights"][content="UK Open Government Licence (OGL)"]', visible: false)
    end
  end
end
