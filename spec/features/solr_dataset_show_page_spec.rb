require "rails_helper"

RSpec.feature "Solr Dataset page", type: :feature do
  let(:response) { JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_dataset.json").to_s)) }
  let(:params) { response["response"]["docs"].first }
  let(:dataset) { SolrDataset.new(params) }
  let(:org_response) { JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_organisation.json").to_s)) }
  let(:organisation) { org_response["response"]["docs"].first }

  before do
    allow(Search::Solr).to receive(:get_by_uuid).and_return(response)
    allow_any_instance_of(RSolr::Client).to receive(:get).and_return(org_response)
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
      expect(page).to have_css("a", text: "All datasets from #{dataset.organisation.title}")
    end
  end

  scenario "Displays the search box" do
    expect(page).to have_css("h3", text: "Search")
    within("form.dgu-search-box") do
      expect(page).to have_content("Search")
    end
  end

  feature "Data links are present" do
    scenario "displays the data links heading" do
      expect(page).to have_css("h2", text: "Data links")
    end

    scenario "displays the table headers" do
      expect(page).to have_css("th", text: "Link to the data")
      expect(page).to have_css("th", text: "Format")
      expect(page).to have_css("th", text: "File added")
      expect(page).to have_css("th", text: "Data preview")
    end

    scenario "displays the list of data files" do
      expect(page).to have_css("td a", count: 12)
    end

    scenario "displays the name of the data file as a link" do
      expect(page).to have_css("td a", text: "Non-consolidated performance related payments 2015-16 (XLS format)")
    end

    scenario "Displays the format of the file if available" do
      expect(page).to have_css("td", text: "XLS")
    end

    scenario "Displays the date of when the file was added" do
      expect(page).to have_css("td", text: "30 June 2017")
    end

    scenario "Show more and show less if more than 5 files", js: true do
      expect(page).to have_css("js-show-more-datafiles", count: 0)
      expect(page).to have_css(".js-datafile-visible", count: 5)
      expect(page).to have_css(".show-toggle", text: "Show more")

      find(".show-toggle").click

      expect(page).to have_css(".js-datafile-visible", count: 12)
      expect(page).to have_css(".show-toggle", text: "Show less")
    end
  end

  feature "Data links are not available" do
    let(:response) { JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_dataset_without_datafiles.json").to_s)) }
    let(:params) { response["response"]["docs"].first }
    let(:dataset) { SolrDataset.new(params) }

    before do
      allow(Search::Solr).to receive(:get_by_uuid).and_return(response)
      visit solr_dataset_path(dataset.id, dataset.name)
    end

    scenario "displays the data links heading" do
      expect(page).to have_css("h2", text: "Data links")
    end

    scenario "a message is displayed to the user" do
      expect(page).to have_content("This data hasn’t been released by the publisher.")
    end

    scenario "a 'not released' label is shown in the metadata box" do
      expect(page).to have_content("Availability: Not released")
    end
  end
end
