require "rails_helper"

RSpec.describe "Header navigation", type: :feature do
  scenario "Toggling the mobile menu", js: true do
    given_i_am_on_the_home_page_on_mobile

    then_the_mobile_menu_is_closed
    and_the_menu_is_not_visible

    when_i_click_the_menu_button
    then_the_mobile_menu_is_open
    and_the_menu_is_visible

    when_i_click_the_menu_button
    then_the_mobile_menu_is_closed
    and_the_menu_is_not_visible
  end

private

  def given_i_am_on_the_home_page_on_mobile
    page.driver.browser.manage.window.resize_to(375, 812)
    visit root_path
  end

  def when_i_click_the_menu_button
    find("button", text: "Menu").click
  end

  def then_the_mobile_menu_is_closed
    expect(find("button", text: "Menu")["aria-expanded"]).to eq("false")
  end

  def and_the_menu_is_not_visible
    expect(page).not_to have_css("#datagovuk-menu-collections", visible: true)
    expect(page).not_to have_css("#datagovuk-menu-data-manual", visible: true)
  end

  def and_the_menu_is_visible
    expect(page).to have_css("#datagovuk-menu-collections", visible: true)
    expect(page).to have_css("#datagovuk-menu-data-manual", visible: true)
  end

  def then_the_mobile_menu_is_open
    expect(find("#datagovuk-header-button-all")["aria-expanded"]).to eq("true")
  end
end
