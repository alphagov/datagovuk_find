require "rails_helper"

RSpec.feature "Solr Dataset page edge cases", type: :feature do
  background do
    given_an_organisation_exists
  end

  scenario "User views a dataset page without datafiles" do
    given_a_dataset_without_datafiles_exists
    when_i_visit_solr_dataset_page(@dataset_no_datafiles)

    then_a_message_indicates_no_data_links_are_available
    and_a_not_released_label_is_displayed
    and_i_can_see_a_notification_banner
    and_the_notification_banner_has_a_link
  end

  scenario "User tries to visit a dataset page that doesn't exist" do
    mock_solr_http_error(status: 404)
    visit dataset_path("invalid-uuid", "invalid-slug")

    expect(page.status_code).to eq(404)
    expect(page).to have_content("Page not found")
  end

  feature "Licence information" do
    scenario "Link to licence for OGL-UK-3.0 dataset" do
      modifed_json_fixture = modified_dataset_validated_data_dict_json(
        "license_id", "OGL-UK-3.0"
      )
      given_a_dataset_exists_and_i_visit_the_page(modifed_json_fixture)

      expect(page)
      .to have_css('meta[name="dc:rights"][content="UK Open Government Licence (OGL)"]', visible: false)
      within(".metadata") do
        expect(page)
          .to have_link("Open Government Licence",
                        href: "https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/")
      end
    end

    scenario "Link to licence with additional info" do
      modifed_json_fixture = modified_dataset_json(
        "extras_licence", "Fair Usage"
      )
      given_a_dataset_exists_and_i_visit_the_page(modifed_json_fixture)

      within("section.meta-data") do
        expect(page)
          .to have_link("View licence information",
                        href: "#licence-info")
      end

      within("section.dgu-licence-info") do
        expect(page).to have_content("Fair Usage")
      end
    end
  end

  def given_a_dataset_without_datafiles_exists
    response_no_datafiles = JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_dataset_without_datafiles.json").to_s))
    params = response_no_datafiles["response"]["docs"].first
    @dataset_no_datafiles = SolrDataset.new(params)
    allow(SolrDataset).to receive(:get_by_uuid).and_return(@dataset_no_datafiles)
  end

  def given_an_organisation_exists
    org_response = JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_organisation.json").to_s))
    allow(Search::Solr).to receive(:get_organisation).and_return(org_response)
  end

  def when_i_visit_solr_dataset_page(dataset)
    visit dataset_path(dataset.uuid, dataset.name)
  end

  def given_a_dataset_exists_and_i_visit_the_page(modifed_json_fixture)
    params = modifed_json_fixture["response"]["docs"].first
    dataset = SolrDataset.new(params)
    allow(SolrDataset).to receive(:get_by_uuid).and_return(dataset)

    visit dataset_path(dataset.uuid, dataset.name)
  end

  def then_a_message_indicates_no_data_links_are_available
    expect(page).to have_css("h2", text: "Data links")
    expect(page).to have_content("This data hasn’t been released by the publisher.")
  end

  def and_a_not_released_label_is_displayed
    expect(page).to have_content("Availability: Not released")
  end

  def and_i_can_see_a_notification_banner
    expect(page).to have_content(I18n.t("shared.notification_banner_title"))
    expect(page).to have_css(".govuk-notification-banner", text: "We're planning improvements to this service. Help us learn what to change by completing a short survey.")
  end

  def and_the_notification_banner_has_a_link
    expect(page).to have_link("completing a short survey", href: "https://forms.gle/9De6rHdmUyVRVTU2A", count: 1)
  end
end
