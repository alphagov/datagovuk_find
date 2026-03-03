require "rails_helper"

RSpec.feature "home", type: :feature do
  scenario "I visit the homepage" do
    given_i_am_on_the_homepage
    then_i_can_see_the_title
    and_i_can_see_the_collections
  end

  def given_i_am_on_the_homepage
    visit "/"
  end

  def then_i_can_see_the_title
    expect(page).to have_content("The home of UK data")
  end

  def and_i_can_see_the_collections
    within(".datagovuk-home-collections") do
      links = [
        "Business and economy",
        "Environment",
        "Government",
        "Land and property",
        "People",
        "Transport",
      ]
      links.each do |link_text|
        expect(page).to have_link(link_text)
      end
    end
  end
end
