require "rails_helper"

RSpec.describe "pages", type: :feature do
  scenario "I visit the home page" do
    given_i_am_on_the_home_page
    then_i_can_see_the_home_page_content
  end

  def given_i_am_on_the_home_page
    visit root_path
  end

  def then_i_can_see_the_home_page_content
    expect(page).to have_content("Test home")
  end
end
