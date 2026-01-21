require "rails_helper"

RSpec.feature "notification banner", type: :feature do
  scenario "I visit the home page" do
    given_i_am_on_the_home_page
    then_i_can_see_a_notification_banner
    and_the_notification_banner_has_a_link
  end

  scenario "I visit the publishers page" do
    given_i_am_on_the_publishers_page
    then_i_can_see_a_notification_banner
    and_the_notification_banner_has_a_link
  end

  scenario "I visit the search results page" do
    given_i_am_on_the_search_results_page
    then_i_can_see_a_notification_banner
    and_the_notification_banner_has_a_link
  end

  scenario "I visit the datasets page" do
    given_an_organisation_exists
    given_a_dataset_exists
    when_i_visit_solr_dataset_page
    then_i_can_see_a_notification_banner
    and_the_notification_banner_has_a_link
  end

  scenario "I visit the cookies page" do
    given_i_am_on_the_cookies_page
    then_i_can_see_a_notification_banner
    and_the_notification_banner_has_a_link
  end

  scenario "I visit the privacy page" do
    given_i_am_on_the_privacy_page
    then_i_can_see_a_notification_banner
    and_the_notification_banner_has_a_link
  end

  scenario "I visit the accessibility page" do
    given_i_am_on_the_accessibility_page
    then_i_can_see_a_notification_banner
    and_the_notification_banner_has_a_link
  end

  scenario "I visit the terms and conditions page" do
    given_i_am_on_the_terms_page
    then_i_can_see_a_notification_banner
    and_the_notification_banner_has_a_link
  end

  scenario "I visit the about page" do
    given_i_am_on_the_about_page
    then_i_can_see_a_notification_banner
    and_the_notification_banner_has_a_link
  end

  scenario "I visit the support page" do
    given_i_am_on_the_support_page
    then_i_can_see_a_notification_banner
    and_the_notification_banner_has_a_link
  end

  scenario "I visit the ckan maintenance page" do
    given_i_am_on_the_ckan_maintenance_page
    then_i_can_see_a_notification_banner
    and_the_notification_banner_has_a_link
  end

  scenario "I visit the site changes page" do
    given_i_am_on_the_site_changes_page
    then_i_can_see_a_notification_banner
    and_the_notification_banner_has_a_link
  end

  def given_i_am_on_the_home_page
    visit root_path
    expect(page).to have_css(".govuk-heading-xl", text: "Find open data")
  end

  def given_i_am_on_the_support_page
    visit support_path
    expect(page).to have_css(".govuk-heading-l", text: "Support")
  end

  def given_i_am_on_the_publishers_page
    visit publishers_path
    expect(page).to have_content("Publish your data")
  end

  def given_i_am_on_the_cookies_page
    visit cookies_path
    expect(page).to have_css(".govuk-heading-xl", text: "Cookies")
  end

  def given_i_am_on_the_privacy_page
    visit privacy_path
    expect(page).to have_css(".govuk-heading-xl", text: "Privacy")
  end

  def given_i_am_on_the_accessibility_page
    visit accessibility_path
    expect(page).to have_css(".govuk-heading-xl", text: "Accessibility")
  end

  def given_i_am_on_the_ckan_maintenance_page
    visit ckan_maintenance_path
    # TODO: Use a govuk heading
    expect(page).to have_css(".heading-large", text: "Data.gov.uk publishing freeze")
  end

  def given_i_am_on_the_site_changes_page
    visit site_changes_path
    # TODO: Use a govuk heading
    expect(page).to have_css(".heading-large", text: "Update about changes to data.gov.uk")
  end

  def given_i_am_on_the_terms_page
    visit terms_path
    expect(page).to have_css(".govuk-heading-xl", text: "Terms and conditions")
  end

  def given_i_am_on_the_about_page
    visit about_path
    expect(page).to have_css(".govuk-heading-xl", text: "About Find open data")
  end

  def given_i_am_on_the_search_results_page
    allow(Search::Solr).to receive(:search).and_return(JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_response.json").to_s)))
    allow(Search::Solr).to receive(:get_organisations).and_return({
      "Aberdeen City Council" => "aberdeen-city-council",
      "Ministry of Housing, Communities and Local Government" => "department-for-communities-and-local-government",
      "Academics" => "academics",
    })
    visit search_path
    expect(page).to have_content("Search results")
  end

  def when_i_visit_solr_dataset_page
    visit dataset_path(@dataset.uuid, @dataset.name)
  end

  def given_a_dataset_exists
    response = JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_dataset.json").to_s))
    params = response["response"]["docs"].first
    @dataset = SolrDataset.new(params)
    allow(SolrDataset).to receive(:get_by_uuid).and_return(@dataset)
  end

  def given_an_organisation_exists
    org_response = JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_organisation.json").to_s))
    allow(Search::Solr).to receive(:get_organisation).and_return(org_response)
  end

  def then_i_can_see_a_notification_banner
    expect(page).to have_content(I18n.t("shared.notification_banner_title"))
    expect(page).to have_css(".govuk-notification-banner", text: "We're planning improvements to this service. Help us learn what to change by completing a short survey.")
  end

  def and_the_notification_banner_has_a_link
    expect(page).to have_link("completing a short survey", href: "https://forms.gle/9De6rHdmUyVRVTU2A", count: 1)
  end
end
