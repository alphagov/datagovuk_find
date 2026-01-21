require "rails_helper"

RSpec.feature "Search results page", type: :feature do
  scenario "User visits the search results page" do
    given_i_am_on_the_search_results_page
    then_i_can_see_the_title
    and_i_can_see_a_notification_banner
    and_the_notification_banner_has_a_link
  end

  def given_i_am_on_the_search_results_page
    allow(Search::Solr).to receive(:search).and_return(JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_response.json").to_s)))
    allow(Search::Solr).to receive(:get_organisations).and_return({
      "Aberdeen City Council" => "aberdeen-city-council",
      "Ministry of Housing, Communities and Local Government" => "department-for-communities-and-local-government",
      "Academics" => "academics",
    })
    visit search_path
  end

  def then_i_can_see_the_title
    expect(page).to have_content("Search results")
  end

  def and_i_can_see_a_notification_banner
    expect(page).to have_content(I18n.t("shared.notification_banner_title"))
    expect(page).to have_css(".govuk-notification-banner", text: "We're planning improvements to this service. Help us learn what to change by completing a short survey.")
  end

  def and_the_notification_banner_has_a_link
    expect(page).to have_link("completing a short survey", href: "https://forms.gle/9De6rHdmUyVRVTU2A", count: 1)
  end
end
