require "rails_helper"

RSpec.feature "Solr Inspire dataset", type: :feature do
  scenario "User views Inspire dataset page" do
    given_an_organisation_exists
    given_an_inspire_dataset_exists
    when_i_visit_solr_dataset_page(@response_inspire, @dataset_inspire)

    # Custom Licence
    then_the_custom_licence_title_is_displayed
    then_the_custom_licence_information_is_displayed

    # Additional Information
    then_the_additional_information_title_is_displayed
    then_the_additional_metadata_summary_is_displayed
    then_the_date_added_to_data_gov_uk_is_displayed
    then_the_access_constraints_are_displayed
    then_the_harvest_guid_is_displayed
    then_the_extent_is_displayed
    then_the_spatial_reference_is_displayed
    then_the_dataset_reference_date_is_displayed
    then_the_frequency_of_update_is_displayed
    then_the_responsible_party_is_displayed
    then_the_iso_19139_resource_type_is_displayed
    then_the_metadata_language_is_displayed
    then_the_inspire_xml_link_is_displayed
    then_the_inspire_html_link_is_displayed

    then_the_publisher_edit_link_is_not_displayed
  end

  def given_an_inspire_dataset_exists
    response_inspire = JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_inspire_dataset.json").to_s))
    params = response_inspire["response"]["docs"].first
    @dataset_inspire = SolrDataset.new(params)
    allow(SolrDataset).to receive(:get_by_uuid).and_return(@dataset_inspire)
  end

  def given_an_organisation_exists
    org_response = JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_organisation.json").to_s))
    allow(Search::Solr).to receive(:get_organisation).and_return(org_response)
  end

  def when_i_visit_solr_dataset_page(_response, dataset)
    visit dataset_path(dataset.uuid, dataset.name)
  end

  def then_the_custom_licence_title_is_displayed
    expect(page).to have_css("section.dgu-licence-info h2", text: "Licence information")
  end

  def then_the_custom_licence_information_is_displayed
    expect(page).to have_css(
      "section.dgu-licence-info",
      text: "Licence information\nUnder the OGL, Land Registry permits you to use the data for commercial or non-commercial purposes. \\n(a) use the polygons (including the associated geometry, namely x,y co-ordinates); or\\Ordnance Survey Public Sector End User Licence - INSPIRE (http://www.ordnancesurvey.co.uk/business-and-government/public-sector/mapping-agreements/inspire-licence.html)",
    )
  end

  def then_the_additional_information_title_is_displayed
    expect(page).to have_css(".dgu-additional-info h2", text: "Additional information")
  end

  def then_the_additional_metadata_summary_is_displayed
    expect(page).to have_css(".dgu-additional-info .summary", text: "View additional metadata")
  end

  def then_the_date_added_to_data_gov_uk_is_displayed
    expect(page).to have_css(".dgu-additional-info", text: "Added to data.gov.uk")
    expect(page).to have_css(".dgu-additional-info", text: "2020-12-14")
  end

  def then_the_access_constraints_are_displayed
    expect(page).to have_css(".dgu-additional-info", text: "Access contraints")
    expect(page).to have_css(".dgu-additional-info", text: "Not specified")
  end

  def then_the_harvest_guid_is_displayed
    expect(page).to have_css(".dgu-additional-info", text: "Harvest GUID")
    expect(page).to have_css(".dgu-additional-info", text: "3df58f2f-a13e-46e9-a657-f532f7ad2fc1")
  end

  def then_the_extent_is_displayed
    expect(page).to have_css(".dgu-additional-info", text: "Extent")
    expect(page).to have_css(".dgu-additional-info", text: "Latitude: 55.80° to ° Longitude: -6.33° to 1.78°")
  end

  def then_the_spatial_reference_is_displayed
    expect(page).to have_css(".dgu-additional-info", text: "Spatial reference")
    expect(page).to have_css(".dgu-additional-info", text: "http://www.opengis.net/def/crs/EPSG/0/27700")
  end

  def then_the_dataset_reference_date_is_displayed
    expect(page).to have_css(".dgu-additional-info", text: "Dataset reference date")
    expect(page).to have_css(".dgu-additional-info", text: "2020-12-29 (publication)")
  end

  def then_the_frequency_of_update_is_displayed
    expect(page).to have_css(".dgu-additional-info", text: "Frequency of update")
    expect(page).to have_css(".dgu-additional-info", text: "monthly")
  end

  def then_the_responsible_party_is_displayed
    expect(page).to have_css(".dgu-additional-info", text: "Responsible party")
    expect(page).to have_css(".dgu-additional-info", text: "HM Land Registry (pointOfContact)")
  end

  def then_the_iso_19139_resource_type_is_displayed
    expect(page).to have_css(".dgu-additional-info", text: "ISO 19139 resource type")
    expect(page).to have_css(".dgu-additional-info", text: "dataset")
  end

  def then_the_metadata_language_is_displayed
    expect(page).to have_css(".dgu-additional-info", text: "Metadata language")
    expect(page).to have_css(".dgu-additional-info", text: "eng")
  end

  def then_the_inspire_xml_link_is_displayed
    expect(page).to have_xpath("//a[@href='/api/2/rest/harvestobject/d35b1574-9823-4fbc-80c0-cd1cc3b84bea/xml']", visible: :all)
  end

  def then_the_inspire_html_link_is_displayed
    expect(page).to have_xpath("//a[@href='/api/2/rest/harvestobject/d35b1574-9823-4fbc-80c0-cd1cc3b84bea/html']", visible: :all)
  end

  def then_the_publisher_edit_link_is_not_displayed
    expect(page).to_not have_css("h2", text: "Edit this dataset")
    expect(page).to_not have_css("p", text: "You must have an account for this publisher on data.gov.uk to make any changes to a dataset.")
    expect(page).to_not have_link("Sign in", href: "/dataset/edit/performance-related-pay-department-for-communities-and-local-government")
  end
end
