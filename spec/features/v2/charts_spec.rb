require "rails_helper"

RSpec.describe "Charts", type: :feature do
  scenario "I can see a line chart on a collection page" do
    given_i_visit_a_collection_page_with_a_line_chart
    then_i_should_see_a_line_chart_with_expected_data
  end

  def given_i_visit_a_collection_page_with_a_line_chart
    visit "/collections/business-and-economy/inflation"
  end

  def then_i_should_see_a_line_chart_with_expected_data
    expect(page).to have_selector("#chart-1")

    html_content = page.html

    expect(html_content).to include('"1992":4.6')

    chart_regex = /new Chartkick\[?.LineChart.*?chart-1.*?1992\\?":4\.6/

    expect(page.html).to match(chart_regex)
  end
end
