require "rails_helper"

RSpec.feature "footer", type: :feature do
  scenario "I visit the homepage" do
    given_i_am_on_the_homepage
    then_i_can_see_the_footer_links
  end

  def given_i_am_on_the_homepage
    visit "/"
  end

  def then_i_can_see_the_footer_links
    within(".datagovuk-footer") do
      links = [
        "Roadmap",
        "Report a problem",
        "Accessibility",
        "Cookies",
        "Privacy and terms",
        "data.gov.uk team",
        "Open Government Licence v3.0",
        "© Crown copyright",
      ]
      links.each do |link_text|
        expect(page).to have_link(link_text)
      end
    end
  end
end
