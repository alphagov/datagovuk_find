require "rails_helper"

RSpec.feature "Solr Search page" do
  scenario "User views and interacts with the search page" do
    given_i_am_on_the_solr_search_page

    then_i_can_see_the_search_heading
    and_i_can_see_the_search_box
    and_i_can_see_the_search_result_count
    and_i_can_see_each_search_result_title
    and_i_can_see_the_publisher_for_each_search_result
    and_i_can_see_the_last_updated_for_each_search_result
    and_i_can_see_results_sorted_by_best_match_by_default

    then_i_can_see_the_filter_by_heading
    and_i_can_see_the_publisher_filter
    and_i_can_see_the_list_of_organisations_in_publisher_filter
    and_i_can_select_an_organisation_in_publisher_filter

    then_i_can_see_the_topic_filter
    and_i_can_see_the_format_filter
    and_i_can_see_the_ogl_filter
    and_i_can_see_the_apply_filters_button
    and_i_can_see_the_remove_filters_link

    when_i_sort_results_by_most_recent
    then_i_can_see_results_sorted_by_most_recent

    then_i_can_see_pagination_info
  end

  def given_i_am_on_the_solr_search_page
    allow(Search::Solr).to receive(:search).and_return(JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_response.json").to_s)))
    allow(Search::Solr).to receive(:get_organisations).and_return({
      "Aberdeen City Council" => "aberdeen-city-council",
      "Ministry of Housing, Communities and Local Government" => "department-for-communities-and-local-government",
      "Academics" => "academics",
    })
    visit "/search/solr"
  end

  def then_i_can_see_the_search_heading
    expect(page).to have_css("h1", text: "Search results")
  end

  def and_i_can_see_the_search_box
    expect(page).to have_content("Search data.gov.uk")
  end

  def and_i_can_see_the_search_result_count
    expect(page).to have_content("2 results found")
  end

  def and_i_can_see_each_search_result_title
    expect(page).to have_css("h2", text: "A very interesting dataset")
    expect(page).to have_css("h2", text: "A dataset with additional inspire metadata")
  end

  def and_i_can_see_the_publisher_for_each_search_result
    results = all(".published_by")
    expect(results.length).to be(2)
    expect(results[0]).to have_content "Ministry of Housing, Communities and Local Government"
    expect(results[1]).to have_content "Mole Valley District Council"
  end

  def and_i_can_see_the_last_updated_for_each_search_result
    expect(page).to have_content("Last updated", count: 2)
    expect(page).to have_content("30 June 2017")
    expect(page).to have_content("17 August 2018")
  end

  def and_i_can_see_results_sorted_by_best_match_by_default
    expect(page).to have_select("sort", selected: "Best match")
  end

  def then_i_can_see_the_filter_by_heading
    expect(page).to have_css("h2", text: "Filter by")
  end

  def and_i_can_see_the_publisher_filter
    expect(page).to have_css(".dgu-filters .govuk-form-group", text: "Publisher")
    expect(page).to have_css("select#publisher")
  end

  def and_i_can_see_the_list_of_organisations_in_publisher_filter
    select_options = all("select#publisher option")
    expect(select_options.length).to be(4)
    expect(select_options[1]).to have_content "Aberdeen City Council"
    expect(select_options[2]).to have_content "Ministry of Housing, Communities and Local Government"
  end

  def and_i_can_select_an_organisation_in_publisher_filter
    select "Ministry of Housing, Communities and Local Government", from: "Publisher"
    click_button "Apply filters"
    expect(page).to have_select("publisher", selected: "Ministry of Housing, Communities and Local Government")
  end

  def then_i_can_see_the_topic_filter
    expect(page).to have_css(".dgu-filters .govuk-form-group", text: "Topic")
    expect(page).to have_css("select#topic")
  end

  def and_i_can_see_the_format_filter
    expect(page).to have_css(".dgu-filters .govuk-form-group", text: "Format")
    expect(page).to have_css("select#format")
  end

  def and_i_can_see_the_ogl_filter
    expect(page).to have_css(".dgu-filters .govuk-form-group", text: "Open Government Licence (OGL) only")
  end

  def and_i_can_see_the_apply_filters_button
    expect(page).to have_css("button", text: "Apply filters")
  end

  def and_i_can_see_the_remove_filters_link
    expect(page).to have_link("Remove filters", href: "/search/solr?q=")
  end

  def when_i_sort_results_by_most_recent
    sorted_solr_search_for("Most recent")
  end

  def then_i_can_see_results_sorted_by_most_recent
    expect(page).to have_select("sort", selected: "Most recent")
  end

  def then_i_can_see_pagination_info
    within(".dgu-pagination") do
      expect(page).to have_content("Displaying all 2 datasets")
    end
  end
end
