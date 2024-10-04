require "rails_helper"

RSpec.describe "Solr Search page", type: :feature do
  let(:results) { File.read(Rails.root.join("spec/fixtures/solr_response.json").to_s) }

  describe "Default search page behaviour" do
    before do
      allow(Search::Solr).to receive(:search).and_return(JSON.parse(results))
    end

    scenario "Displays search heading" do
      visit "/search/solr"
      expect(page).to have_css("h1", text: "Search results")
    end

    scenario "Displays search box" do
      visit "/search/solr"
      expect(page).to have_content("Search data.gov.uk")
    end

    scenario "Displays search results" do
      visit "/search/solr"
      expect(page).to have_content("2 results found")
    end

    scenario "Displays the title for each search result" do
      visit "/search/solr"
      expect(page).to have_css("h2", text: "A very interesting dataset")
      expect(page).to have_css("h2", text: "A dataset with additional inspire metadata")
    end

    scenario "Displays the publisher for each search result" do
      visit "/search/solr"
      results = all(".published_by")
      expect(results.length).to be(2)
      expect(results[0]).to have_content "Ministry of Housing, Communities and Local Government"
      expect(results[1]).to have_content "Mole Valley District Council"
    end

    scenario "Displays the last updated for each search result" do
      visit "/search/solr"
      expect(page).to have_content("Last updated", count: 2)
      expect(page).to have_content("30 June 2017")
      expect(page).to have_content("17 August 2018")
    end

    scenario "Results are sorted by best match" do
      visit "/search/solr"
      expect(page).to have_select("sort", selected: "Best match")
    end
  end

  describe "When a user filters the results" do
    before do
      allow(Search::Solr).to receive(:search).and_return(JSON.parse(results))
    end

    scenario "Results are sorted by best match" do
      filtered_solr_search_for("Best match")
      expect(page).to have_select("sort", selected: "Best match")
    end

    scenario "Results are sorted by most recent" do
      filtered_solr_search_for("Most recent")
      expect(page).to have_select("sort", selected: "Most recent")
    end
  end
end
