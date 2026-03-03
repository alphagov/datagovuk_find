require "rails_helper"

RSpec.feature "data manual", type: :feature do
  scenario "I visit the data manual homepage" do
    given_i_am_on_the_data_manual_homepage
    then_i_can_see_the_data_manual_title("Data manual")
  end

  def given_i_am_on_the_data_manual_homepage
    visit "/data-manual"
  end

  def then_i_can_see_the_data_manual_title(title)
    expect(page).to have_content(title)
  end
end
