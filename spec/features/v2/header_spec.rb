require "rails_helper"

RSpec.describe "header", type: :feature do
  scenario "I visit the home page" do
    given_i_am_on_the_home_page
    then_i_can_see_the_header
    and_top_navigation_has_drop_down_of_collections
    and_i_click_on_collections_menu_button
    then_i_can_see_the_collections_menu
    and_i_click_on_data_manual_menu_button
    then_i_can_see_the_data_manual_menu
  end

  def given_i_am_on_the_home_page
    visit root_path
  end

  def then_i_can_see_the_header
    expect(page).to have_css(".datagovuk-header")
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

  def then_i_can_see_the_collections_menu
    expect(page).to have_css("#datagovuk-header-button-collections", visible: true)
  end

  def and_i_click_on_collections_menu_button
    find("#datagovuk-header-button-collections").click
  end

  def then_i_can_see_the_collections_menu
    expect(page).to have_css("#datagovuk-header-button-collections", visible: true)
  end

  def and_i_click_on_data_manual_menu_button
    find("#datagovuk-header-button-data-manual").click
  end

  def then_i_can_see_the_data_manual_menu
    expect(page).to have_css("#datagovuk-header-button-data-manual", visible: true)
  end
end
