require "rails_helper"

RSpec.feature "Search directory page", type: :feature do
  scenario "User visits the search directory page" do
    given_i_am_on_the_search_directory_page
    then_i_can_see_the_title
    and_i_can_see_a_notification_banner
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

  def then_i_can_see_the_title
    expect(page).to have_content("Search directory")
  end

  def and_i_can_see_a_notification_banner
    expect(page).to have_content("data.gov.uk is changing and you may experience some issues with the data in this directory.")
  end
end
