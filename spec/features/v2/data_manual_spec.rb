require "rails_helper"

RSpec.feature "data manual", type: :feature do
  scenario "I visit the data manual homepage" do
    given_i_am_on_the_data_manual_homepage
    then_i_can_see_the_content("Data manual")
  end

  scenario "I visit a data manual content page" do
    given_i_am_on_a_data_manual_content_page
    then_i_can_see_the_content("Who this manual is for")
  end

  def given_i_am_on_the_data_manual_homepage
    visit "/data-manual"
  end

  def given_i_am_on_a_data_manual_content_page
    visit "/data-manual/who-this-manual-is-for"
  end

  def then_i_can_see_the_content(title)
    expect(page).to have_content(title)
  end
end
