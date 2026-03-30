require "rails_helper"

RSpec.feature "collections", type: :feature do
  before(:all) do
    Rake.application.rake_require("tasks/markdown_to_static_html")
    Rake::Task.define_task(:environment)
    Rake::Task["markdown:render"].invoke
  end

  after(:all) do
    output_directory = Rails.configuration.x.markdown_collections_output_location
    FileUtils.rm_rf(output_directory)
  end

  scenario "I visit a collection page" do
    given_i_am_on_a_collection_page
    then_i_can_see_the_collection_title("Business and economy")
    then_i_can_see_the_topic_content("Inflation")
    and_i_can_see_the_main_links
    and_i_can_see_the_feedback_form
    and_i_can_see_the_collection_header_underline
    and_the_download_chart_data_link_exists
  end

  def and_the_download_chart_data_link_exists
    expect(page).to have_link("Download the chart data", href: "/collections/business-and-economy/inflation/charts/inflation-1989-2025.csv")
  end

  def and_i_can_see_the_main_links
    expect(page).to have_link("Inflation and price indices", href: "https://www.ons.gov.uk/economy/inflationandpriceindices")
  end

  def and_i_can_see_the_collection_header_underline
    expect(page).to have_css(".datagovuk-collection-header__underline")
  end

  def and_i_can_see_the_feedback_form
    expect(page).to have_css(".govuk-inset-text.datagovuk-feedback-inset-text")
    expect(page).to have_link("Give us feedback")
  end

  def given_i_am_on_a_collection_page
    visit "/collections/business-and-economy/inflation"
  end

  def then_i_can_see_the_collection_title(title)
    expect(page).to have_content(title)
  end

  def then_i_can_see_the_topic_content(topic_name)
    case topic_name
    when "Inflation"
      expect(page).to have_css("h1", exact_text: "Inflation")
    when "Energy prices"
      expect(page).to have_css("h1", exact_text: "Energy prices")
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
