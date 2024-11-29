require "rails_helper"

RSpec.feature "Solr Dataset page", type: :feature do
  background do
    given_an_organisation_exists
    given_a_dataset_exists
    when_i_visit_solr_dataset_page
  end

  scenario "User views standard dataset page with datafiles (JavaScript disbled)" do
    # Meta information
    then_the_meta_title_tag_is_correct
    and_the_meta_creator_tag_is_correct
    and_the_meta_date_tag_is_correct
    and_the_meta_licence_tag_is_correct

    # Licence information
    then_the_ogl_licence_link_is_displayed

    # Metadata box
    then_the_publisher_name_is_displayed
    and_the_last_updated_date_is_correct
    and_the_topic_is_displayed_if_present
    and_the_summary_is_displayed

    # Sidebar
    then_the_publisher_datasets_link_is_displayed
    then_the_search_box_is_displayed

    # Data links
    then_the_data_links_heading_is_displayed
    and_the_table_headers_are_correct
    and_the_list_of_data_files_is_displayed_with_count_of(12)
    and_the_file_details_are_correct

    # Contact information
    then_enquiries_details_are_displayed
    and_foi_details_are_displayed

    # Supporting documents
    then_the_supporting_documents_are_displayed
    and_supporting_documents_details_are_correct

    then_the_custom_licence_is_not_displayed
    then_the_additional_information_is_not_displayed

    then_the_publisher_edit_link_is_displayed
  end

  scenario "User views standard dataset page with datafiles (JavaScript enabled)", js: true do
    # Data links
    then_the_list_of_data_files_is_displayed_with_count_of(5)
    and_show_more_and_show_less_functionality_is_working
  end

  def given_a_dataset_exists
    @response = JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_dataset.json").to_s))
    params = @response["response"]["docs"].first
    @dataset = SolrDataset.new(params)
  end

  def given_an_organisation_exists
    org_response = JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_organisation.json").to_s))
    allow(Search::Solr).to receive(:get_organisation).and_return(org_response)
  end

  def when_i_visit_solr_dataset_page
    allow(Search::Solr).to receive(:get_by_uuid).and_return(@response)
    visit solr_dataset_path(@dataset.id, @dataset.name)
  end

  def then_the_meta_title_tag_is_correct
    expect(page).to have_css('meta[name="dc:title"][content="A very interesting dataset"]', visible: false)
  end

  def and_the_meta_creator_tag_is_correct
    expect(page).to have_css('meta[name="dc:creator"][content="Ministry of Housing, Communities and Local Government"]', visible: false)
  end

  def and_the_meta_date_tag_is_correct
    expect(page).to have_css('meta[name="dc:date"][content="2017-06-30"]', visible: false)
  end

  def and_the_meta_licence_tag_is_correct
    expect(page).to have_css('meta[name="dc:rights"][content="UK Open Government Licence (OGL)"]', visible: false)
  end

  def then_the_ogl_licence_link_is_displayed
    within(".metadata") do
      expect(page).to have_link("Open Government Licence", href: "https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/")
    end
  end

  def then_the_publisher_name_is_displayed
    expect(page).to have_content("Published by: Ministry of Housing, Communities and Local Government")
  end

  def and_the_last_updated_date_is_correct
    expect(page).to have_content("Last updated: 30 June 2017")
  end

  def and_the_topic_is_displayed_if_present
    expect(page).to have_content("Topic: Government")
  end

  def and_the_summary_is_displayed
    expect(page).to have_content("Lorem ipsum dolor sit amet.")
  end

  def then_the_publisher_datasets_link_is_displayed
    expect(page).to have_css("a", text: "All datasets from #{@dataset.organisation.title}")
  end

  def then_the_search_box_is_displayed
    expect(page).to have_css("h3", text: "Search")
    within("form.dgu-search-box") do
      expect(page).to have_content("Search")
    end
  end

  def then_the_data_links_heading_is_displayed
    expect(page).to have_css("h2", text: "Data links")
  end

  def and_the_table_headers_are_correct
    expect(page).to have_css("th", text: "Link to the data")
    expect(page).to have_css("th", text: "Format")
    expect(page).to have_css("th", text: "File added")
    expect(page).to have_css("th", text: "Data preview")
  end

  def and_the_list_of_data_files_is_displayed_with_count_of(count)
    expect(page).to have_css(".dgu-datalinks td a", count:)
  end

  alias_method :then_the_list_of_data_files_is_displayed_with_count_of, :and_the_list_of_data_files_is_displayed_with_count_of

  def and_the_file_details_are_correct
    expect(page).to have_css("td a", text: "Non-consolidated performance related payments 2015-16 (XLS format)")
    expect(page).to have_css("td", text: "XLS")
    expect(page).to have_css("td", text: "30 June 2017")
  end

  def and_show_more_and_show_less_functionality_is_working
    expect(page).to have_css(".js-datafile-visible", count: 5)
    find(".show-toggle").click
    expect(page).to have_css(".js-datafile-visible", count: 12)
    find(".show-toggle").click
    expect(page).to have_css(".js-datafile-visible", count: 5)
  end

  def then_enquiries_details_are_displayed
    expect(page).to have_css("h3", text: "Enquiries")
    expect(page).to have_link(
      "Contact Ministry of Housing, Communities and Local Government regarding this dataset",
      href: "http://forms.communities.gov.uk/",
    )
  end

  def and_foi_details_are_displayed
    expect(page).to have_css("h3", text: "Freedom of Information (FOI) requests")
    expect(page).to have_link("DCLG FOI enquiries", href: "mailto:foirequests@communities.gsi.gov.uk")
  end

  def then_the_supporting_documents_are_displayed
    expect(page).to have_css(".docs td a", count: 2)
  end

  def and_supporting_documents_details_are_correct
    expect(page).to have_css(".docs th", text: "Link to the document")
    expect(page).to have_css(".docs th", text: "Format")
    expect(page).to have_css(".docs th", text: "Date added")

    expect(page).to have_css(".docs td a", text: "Technical specification")
    expect(page).to have_css(".docs td a", text: "No name specified")
    expect(page).to have_css(".docs td", text: "HTML")
    expect(page).to have_css(".docs td", text: "N/A")
    expect(page).to have_css(".docs td", text: "02 July 2020")
  end

  def then_the_custom_licence_is_not_displayed
    expect(page).to_not have_css("section.dgu-licence-info h2", text: "Licence information")
    expect(page).to_not have_css("section.dgu-licence-info")
  end

  def then_the_additional_information_is_not_displayed
    expect(page).to_not have_css(".dgu-additional-info h2", text: "Additional information")
    expect(page).to_not have_css(".dgu-additional-info .summary", text: "View additional metadata")
    expect(page).to_not have_css(".dgu-deflist")
  end

  def then_the_publisher_edit_link_is_displayed
    expect(page).to have_css("h2", text: "Edit this dataset")
    expect(page).to have_css("p", text: "You must have an account for this publisher on data.gov.uk to make any changes to a dataset.")
    expect(page).to have_link("Sign in", href: "/dataset/edit/a-very-interesting-dataset")
  end
end
