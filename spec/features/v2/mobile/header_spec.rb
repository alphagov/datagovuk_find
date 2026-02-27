require "rails_helper"

RSpec.describe "header", type: :feature do
  scenario "viewing the header on mobile", js: true do
    given_i_am_on_the_home_page
    and_im_on_mobile_view
    then_i_can_see_a_menu_button
    and_i_do_not_see_the_collections_menu
    and_i_do_not_see_the_data_manual_menu
    then_i_click_on_the_menu_button
    and_i_can_see_the_collections_menu
    and_i_can_see_the_data_manual_menu
    and_i_click_on_collections_menu
    then_i_do_not_see_the_data_manual_menu
    and_i_do_not_see_the_collections_menu
  end

  def given_i_am_on_the_home_page
    visit root_path
  end

  def and_im_on_mobile_view
    page.driver.browser.manage.window.resize_to(375, 812)
    expect(page).to have_css(".datagovuk-header__button", visible: true)
  end

  def then_i_can_see_a_menu_button
    expect(page).to have_css("#datagovuk-header-button-all", visible: true)
  end

  def and_i_do_not_see_the_collections_menu
    expect(page).to have_css("#datagovuk-menu-collections", visible: false)
  end

  def and_i_do_not_see_the_data_manual_menu
    expect(page).to have_css("#datagovuk-menu-data-manual", visible: false)
  end

  def then_i_click_on_the_menu_button
    find("#datagovuk-header-button-all").click
  end

  def and_i_can_see_the_collections_menu
    expect(page).to have_css("#datagovuk-menu-collections", visible: true)
  end

  def and_i_click_on_collections_menu
    find("#datagovuk-menu-collections").click
  end

  def and_i_can_see_the_data_manual_menu
    expect(page).to have_css("#datagovuk-menu-data-manual", visible: true)
  end

  def then_i_do_not_see_the_data_manual_menu
    expect(page).to have_css("#datagovuk-menu-data-manual", visible: false)
  end
end
