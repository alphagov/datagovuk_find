require "rails_helper"

RSpec.feature "collections", type: :feature do
  scenario "I visit a collection page" do
    given_i_am_on_the_collection_page
    and_top_navigation_has_drop_down_of_collections
    then_i_can_see_the_collection_title("Land and property")
  end

  def given_i_am_on_the_collection_page
    visit "/collections/land-and-property/property-price-paid"
  end

  def then_i_can_see_the_collection_title(title)
    expect(page).to have_content(title)
  end

  def then_i_can_see_the_topic_content(topic_name)
    case topic_name
    when "Property price paid"
      expect(page).to have_content("Find property transactions through HM Land Registry by searching on address")
    when "Planning data"
      expect(page).to have_content("")
    end
  end

  def and_top_navigation_has_drop_down_of_collections
    within(".dgu-nav-dropdown__menu") do
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
