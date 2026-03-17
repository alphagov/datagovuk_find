require "rails_helper"

RSpec.describe "Charts", type: :feature do
  scenario "I can see a single series line chart on a collection page" do
    given_i_visit_a_collection_page_with_a_single_series_line_chart
    then_i_should_see_a_line_chart_with_expected_data
    and_i_should_see_a_download_link_for_the_chart_data("Download the chart data", "/charts/inflation/inflation-1989-2025/download")
  end

  def given_i_visit_a_collection_page_with_a_single_series_line_chart
    visit "/collections/business-and-economy/inflation"
  end

  def and_i_should_see_a_download_link_for_the_chart_data(link_description, href)
    expect(page).to have_link(link_description, href: href)
  end

  def then_i_should_see_a_line_chart_with_expected_data
    expect(page).to have_selector("#chart-1")

    html_content = page.html

    expect(html_content).to include('"1992":4.6')

    chart_regex = /new Chartkick\[?.LineChart.*?chart-1.*?1992\\?":4\.6/

    expect(page.html).to match(chart_regex)
  end

  scenario "I can see a bar chart on a collection page" do
    given_i_visit_a_collection_page_with_a_bar_chart
    then_i_should_see_a_bar_chart_with_expected_data
    and_i_should_see_a_download_link_for_the_chart_data("Download the chart data", "/charts/vote-share/vote-share-at-least-1-seat-won/download")
  end

  def given_i_visit_a_collection_page_with_a_bar_chart
    visit "/collections/government/election-results-data"
  end

  def then_i_should_see_a_bar_chart_with_expected_data
    html = CGI.unescapeHTML(page.html)
    expect(html).to include('new Chartkick["BarChart"]("chart-1"')
    expect(html).to match(/\["Labour",\s?33\.7\]/)
    expect(html).to match(/\["Conservative",\s?23\.7\]/)
    expect(html).to include('"indexAxis":"y"')
    expect(html).to include('"colors":["#C27A9A"]')
  end
end
