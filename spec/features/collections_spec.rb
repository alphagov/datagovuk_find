require "rails_helper"

RSpec.feature "collections", type: :feature do
  scenario "I visit a collection page" do
    given_i_am_on_the_collection_page
    and_top_navigation_has_drop_down_of_collections
    then_i_can_see_the_collection_title("Land and property")
    then_i_can_see_the_topic_content("Property price paid")
    and_i_can_see_the_feedback_form
    and_i_can_see_the_topic_data_links
    and_i_can_see_the_collection_header_underline
  end

  def and_i_can_see_more_information_links
    expect(page).to have_link("More information", href: "https://landregistry.data.gov.uk/app/ppd/")
    expect(page).to have_link("API documentation", href: "https://use-land-property-data.service.gov.uk/api-information")
  end

  def and_i_can_see_the_collection_header_underline
    expect(page).to have_css(".datagovuk-collection-header__underline")
  end

  def and_i_can_see_the_feedback_form
    expect(page).to have_css(".govuk-inset-text.datagovuk-feedback-inset-text")
    expect(page).to have_link("Give us feedback", href: "#feedback")
  end

  def and_i_can_see_the_topic_data_links
    expect(page).to have_link("Dataset", href: "https://www.gov.uk/government/statistical-data-sets/price-paid-data-downloads")
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
      expect(page).to have_content(/Find property transactions through HM Land Registry/)
    when "Planning data"
      expect(page).to have_content("")
    end
  end

  def and_top_navigation_has_drop_down_of_collections
    within("#datagovuk-menu-collections") do
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
