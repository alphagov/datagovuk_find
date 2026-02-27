require "rails_helper"

RSpec.feature "collections", type: :feature do
  scenario "I visit a collection page" do
    given_i_am_on_a_collection_page
    and_top_navigation_has_drop_down_of_collections
    then_i_can_see_the_collection_title("Land and property")
    then_i_can_see_the_topic_content("UK House prices")
    and_i_can_see_the_main_links
    and_i_can_see_the_feedback_form
    and_i_can_see_the_collection_header_underline
  end

  def and_i_can_see_the_main_links
    expect(page).to have_link("Search UK house price index", href: "https://landregistry.data.gov.uk/app/ukhpi/")
    expect(page).to have_link("Download UK house price index", href: "https://www.gov.uk/government/statistical-data-sets/uk-house-price-index-data-downloads-november-2025")
  end

  def and_i_can_see_the_collection_header_underline
    expect(page).to have_css(".datagovuk-collection-header__underline")
  end

  def and_i_can_see_the_feedback_form
    expect(page).to have_css(".govuk-inset-text.datagovuk-feedback-inset-text")
    expect(page).to have_link("Give us feedback", href: "#feedback")
  end


  def given_i_am_on_a_collection_page
    visit "/collections/land-and-property/uk-house-prices"
  end

  def then_i_can_see_the_collection_title(title)
    expect(page).to have_content(title)
  end

  def then_i_can_see_the_topic_content(topic_name)
    case topic_name
    when "UK House prices"
      expect(page).to have_content(/Search the UK house price index/)
    end
  end

  def and_top_navigation_has_drop_down_of_collections
    within("#datagovuk-menu-collections") do
      links = [
        "Business and economy",
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
