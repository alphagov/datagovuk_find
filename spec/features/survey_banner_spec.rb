require "rails_helper"

RSpec.feature "Survey banner", type: :feature, js: true do
  before do
    allow(Search::Solr).to receive(:search).and_return(JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_response.json").to_s)))
    allow(Search::Solr).to receive(:get_organisations).and_return({})
  end

  scenario "Survey banner is visible on page load" do
    given_i_am_on_the_search_page
    then_banner_is_visible
    and_i_dismiss_the_banner
    then_banner_is_not_visible
  end

  scenario "Survey banner stays hidden after rejecting additional cookies" do
    given_i_am_on_the_search_page
    then_i_reject_additional_cookies
    and_i_dismiss_the_banner
    and_i_refresh_the_page
    then_banner_is_not_visible
  end

  def then_i_reject_additional_cookies
    click_button "Reject additional cookies"
  end

  def and_i_dismiss_the_banner
    find(".datagovuk-close").click
  end

  def given_i_am_on_the_search_page
    visit search_path
  end

  def and_i_refresh_the_page
    visit current_path
  end

  def then_banner_is_visible
    expect(page).to have_content("Help us improve the National Data Library")
  end

  def then_banner_is_not_visible
    expect(page).not_to have_content("Help us improve the National Data Library")
  end
end
