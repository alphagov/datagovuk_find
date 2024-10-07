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

  feature "Metadata box" do
    scenario "Displays the publisher name" do
      expect(page).to have_content("Published by: Ministry of Housing, Communities and Local Government")
    end

    scenario "'Last updated' field displays public_updated_at" do
      expect(page).to have_content("Last updated: 30 June 2017")
    end

    scenario "Displays the topic if there is one" do
      expect(page).to have_content("Topic: Government")
    end

    scenario "Displays the summary" do
      expect(page).to have_content("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec euismod mauris in augue laoreet congue. Phasellus bibendum leo vel magna lacinia eleifend. Nam vitae lectus quis nulla varius faucibus id quis nibh. Nullam auctor ipsum non nunc efficitur bibendum Sed vitae ex nisi. Suspendisse posuere purus ac dui posuere, in interdum risus ornare.\nThe following files can be found on the website here:\nhttps://www.gov.uk/")
    end
  end

  feature "Show more from publisher" do
    scenario "Displays the link publisher's datasets" do
      expect(page).to have_content("More from this publisher")
      expect(page).to have_css("a", text: "All datasets from #{dataset.organisation['title']}")
    end
  end
end
