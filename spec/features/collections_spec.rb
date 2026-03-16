require "rails_helper"

RSpec.feature "collections", type: :feature do
  scenario "I visit a collection page" do
    given_i_am_on_a_collection_page
    and_top_navigation_has_drop_down_of_collections
    then_i_can_see_the_collection_title("Land and property")
    then_i_can_see_the_topic_content("Planning data")
    and_i_can_see_the_main_links
    and_i_can_see_the_feedback_form
    and_i_can_see_the_collection_header_underline
  end

  def and_i_can_see_the_main_links
    expect(page).to have_link("Planning and housing data", href: "https://www.planning.data.gov.uk")
    expect(page).to have_link("Planning Data API", href: "https://www.planning.data.gov.uk/docs")
    expect(page).to have_link("Planning data datasets", href: "https://www.planning.data.gov.uk/dataset/")
  end

  def and_i_can_see_the_collection_header_underline
    expect(page).to have_css(".datagovuk-collection-header__underline")
  end

  def and_i_can_see_the_feedback_form
    expect(page).to have_css(".govuk-inset-text.datagovuk-feedback-inset-text")
    expect(page).to have_link("Give us feedback")
  end

  def given_i_am_on_a_collection_page
    visit "/collections/land-and-property/planning-data"
  end

  def then_i_can_see_the_collection_title(title)
    expect(page).to have_content(title)
  end

  def then_i_can_see_the_topic_content(topic_name)
    case topic_name
    when "Planning data"
      expect(page).to have_content(/The planning datasets page allows you to download a range of datasets/)
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
