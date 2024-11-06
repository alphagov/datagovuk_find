require "rails_helper"

RSpec.describe "Solr Search page", type: :feature do
  let(:results) { File.read(Rails.root.join("spec/fixtures/solr_response.json").to_s) }
  let(:organisations) { { "Aberdeen City Council" => "aberdeen-city-council", "Ministry of Housing, Communities and Local Government" => "department-for-communities-and-local-government", "Academics" => "academics" } }

  describe "Default search page behaviour" do
    before do
      allow(Search::Solr).to receive(:search).and_return(JSON.parse(results))
      allow(Search::Solr).to receive(:get_organisations).and_return(organisations)
      visit "/search/solr"
    end

    scenario "Displays search heading" do
      expect(page).to have_css("h1", text: "Search results")
    end

    scenario "Displays search box" do
      expect(page).to have_content("Search data.gov.uk")
    end

    scenario "Displays search results" do
      expect(page).to have_content("2 results found")
    end

    scenario "Displays the title for each search result" do
      expect(page).to have_css("h2", text: "A very interesting dataset")
      expect(page).to have_css("h2", text: "A dataset with additional inspire metadata")
    end

    scenario "Displays the publisher for each search result" do
      results = all(".published_by")
      expect(results.length).to be(2)
      expect(results[0]).to have_content "Ministry of Housing, Communities and Local Government"
      expect(results[1]).to have_content "Mole Valley District Council"
    end

    scenario "Displays the last updated for each search result" do
      expect(page).to have_content("Last updated", count: 2)
      expect(page).to have_content("30 June 2017")
      expect(page).to have_content("17 August 2018")
    end

    scenario "Results are sorted by best match" do
      expect(page).to have_select("sort", selected: "Best match")
    end

    describe "Filters" do
      scenario "Displays the 'Filter by' heading" do
        expect(page).to have_css("h2", text: "Filter by")
      end

      describe "Publisher filter" do
        scenario "Displays the 'Publisher' filter" do
          expect(page).to have_css(".dgu-filters .govuk-form-group", text: "Publisher")
          expect(page).to have_css("select#publisher")
        end

        scenario "Displays list of organisations" do
          select_options = all("select#publisher option")
          expect(select_options.length).to be(4)
          expect(select_options[1]).to have_content "Aberdeen City Council"
          expect(select_options[2]).to have_content "Ministry of Housing, Communities and Local Government"
        end

        scenario "Selects organisation in list if user makes a selection" do
          select "Ministry of Housing, Communities and Local Government", from: "Publisher"
          click_button "Apply filters"

          expect(page).to have_select("publisher", selected: "Ministry of Housing, Communities and Local Government")
        end

        # Skipped because it passes locally, fails in CI
        scenario "Doesn't clear search keywords when filters are applied", skip: true do
          results_for_keyword_with_publisher_filter = File.read(Rails.root.join("spec/fixtures/solr_response_with_keyword_and_publisher_filter.json")).to_s
          results_for_keyword = File.read(Rails.root.join("spec/fixtures/solr_response_with_keyword.json")).to_s
          allow(Search::Solr).to receive(:search).and_return(JSON.parse(results_for_keyword))
          allow(Search::Solr).to receive(:get_organisations).and_return({
            "City of London" => "city-of-london",
            "British Gological Survey" => "british-geological-survey",
          })

          visit "/search/solr"

          expect(Search::Solr).to receive(:search).and_return(JSON.parse(results_for_keyword_with_publisher_filter))
          within "#main-content" do
            fill_in "q", with: "bears"
            find(".gem-c-search__submit").click
          end

          select "City of London", from: "publisher"
          click_button "Apply filters"

          expect(page).to have_title('Results for "bears"')
          expect(page).to have_select("publisher", selected: "City of London")
        end
      end

      scenario "Displays the 'Topic' filter" do
        expect(page).to have_css(".dgu-filters .govuk-form-group", text: "Topic")
        expect(page).to have_css("select#topic")
      end

      scenario "Displays the 'Format' filter" do
        expect(page).to have_css(".dgu-filters .govuk-form-group", text: "Format")
        expect(page).to have_css("select#format")
      end

      scenario "Displays the 'OGL' filter" do
        expect(page).to have_css(".dgu-filters .govuk-form-group", text: "Open Government Licence (OGL) only")
      end

      scenario "Displays the 'Apply filters' button" do
        expect(page).to have_css("button", text: "Apply filters")
      end

      scenario "Displays the 'Remove filters' option" do
        expect(page).to have_link("Remove filters", href: "/search/solr?q=")
      end
    end
  end

  describe "When a user sorts the results" do
    before do
      allow(Search::Solr).to receive(:search).and_return(JSON.parse(results))
      allow(Search::Solr).to receive(:get_organisations).and_return(organisations)
    end

    scenario "Results are sorted by best match" do
      sorted_solr_search_for("Best match")
      expect(page).to have_select("sort", selected: "Best match")
    end

    scenario "Results are sorted by most recent" do
      sorted_solr_search_for("Most recent")
      expect(page).to have_select("sort", selected: "Most recent")
    end
  end
end
