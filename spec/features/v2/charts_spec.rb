require "rails_helper"

RSpec.describe "Charts", type: :system, js: true do
  # Setup and teardown for generated views is handled globally in rails_helper.rb

  scenario "I can see a single series line chart on a collection page" do
    given_i_visit_a_collection_page_with_a_single_series_line_chart
    then_i_should_see_a_line_chart_with_expected_data
    and_i_should_see_a_download_link_for_the_chart_data("Download the chart data", "/collections/business-and-economy/inflation/charts/inflation-1989-2025.csv")
  end

  scenario "I can see a bar chart on a collection page" do
    given_i_visit_a_collection_page_with_a_bar_chart
    then_i_should_see_a_bar_chart_with_expected_data
    and_i_should_see_a_download_link_for_the_chart_data("Download the chart data", "/collections/government/election-results/charts/vote-share-at-least-1-seat-won.csv")
  end

  scenario "I can see a headline chart on a collection page" do
    given_i_visit_a_collection_page_with_a_headline_chart
    then_i_should_see_a_headline_chart_with_expected_data
    and_i_should_not_see_a_download_link_for_the_chart_data
  end

private

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

    chart_regex = /new Chartkick(?:\.|\s*\[\s*")LineChart(?:"]\s*)?\(.*?"chart-1".*?"1992":\s*4\.6/m

    expect(page.html).to match(chart_regex)
  end

  def given_i_visit_a_collection_page_with_a_bar_chart
    visit "/collections/government/election-results"
  end

  def then_i_should_see_a_bar_chart_with_expected_data
    within(".bar-chart") do
      expect(page).to have_selector("canvas")
    end
  end

  def given_i_visit_a_collection_page_with_a_headline_chart
    visit "/collections/transport/road-traffic"
  end

  def then_i_should_see_a_headline_chart_with_expected_data
    expect(page).to have_css(".datagovuk-headline__columns")
  end

  def and_i_should_not_see_a_download_link_for_the_chart_data
    expect(page).not_to have_link("Download the chart data")
  end
end
