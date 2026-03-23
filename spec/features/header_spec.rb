require "rails_helper"

RSpec.feature "directory header", type: :feature do
  scenario "displays the directory header" do
    given_i_am_on_the_search_directory_page
    and_i_can_see_a_link_to_the_search_directory
    then_i_can_se_the_directory_link
    and_i_can_see_a_link_to_the_search_directory_in_the_mobile_menu
  end

  def given_i_am_on_the_search_directory_page
    allow(Search::Solr).to receive(:search).and_return(JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_response.json").to_s)))
    allow(Search::Solr).to receive(:get_organisations).and_return({
      "Aberdeen City Council" => "aberdeen-city-council",
      "Ministry of Housing, Communities and Local Government" => "department-for-communities-and-local-government",
      "Academics" => "academics",
    })
    visit search_path
  end

  def and_i_can_see_a_link_to_the_search_directory
    within(".govuk-header") do
      expect(page).to have_link("Directory", href: search_path, class: "govuk-header__link--homepage")
    end
  end

  def and_i_can_see_a_link_to_the_search_directory_in_the_mobile_menu
    find(".govuk-header__menu-button").click
    within("#navigation") do
      expect(page).to have_link("Publish your data", href: "/publishers")
      expect(page).to have_link("Documentation", href: "https://guidance.data.gov.uk/publish_and_manage_data/")
      expect(page).to have_link("Support", href: "/support")
    end
  end

  def then_i_can_se_the_directory_link
    within(".datagovuk-header") do
      expect(page).to have_link("Directory", href: search_path, class: "datagovuk-header__link")
    end
  end
end
