require "rails_helper"

RSpec.feature "Home page", type: :feature do
  scenario "User visits the home page" do
    given_i_am_on_the_home_page
    then_i_can_see_the_title
    and_i_can_see_a_notification_banner
    and_the_notification_banner_has_a_link
  end

  def given_i_am_on_the_home_page
    visit root_path
  end

  def then_i_can_see_the_title
    expect(page).to have_content("Find open data")
  end

  def and_i_can_see_a_notification_banner
    expect(page).to have_content(I18n.t(".pages.home.notification_banner_title"))
    expect(page).to have_css(".govuk-notification-banner", text: "We're planning improvements to this service. Help us learn what to change by completing a short survey.")
  end

  def and_the_notification_banner_has_a_link
    expect(page).to have_link("completing a short survey", href: "https://surveys.publishing.service.gov.uk/s/OSC03D/", count: 1)
  end
end
