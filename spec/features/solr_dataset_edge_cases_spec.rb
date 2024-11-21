require "rails_helper"

RSpec.feature "Solr Dataset page edge cases", type: :feature do
  scenario "User views a dataset page without datafiles" do
    given_an_organisation_exists
    given_a_dataset_without_datafiles_exists
    when_i_visit_solr_dataset_page(@response_no_datafiles, @dataset_no_datafiles)

    then_a_message_indicates_no_data_links_are_available
    and_a_not_released_label_is_displayed
  end

  def given_a_dataset_without_datafiles_exists
    @response_no_datafiles = JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_dataset_without_datafiles.json").to_s))
    params = @response_no_datafiles["response"]["docs"].first
    @dataset_no_datafiles = SolrDataset.new(params)
  end

  def given_an_organisation_exists
    org_response = JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_organisation.json").to_s))
    allow(Search::Solr).to receive(:get_organisation).and_return(org_response)
  end

  def when_i_visit_solr_dataset_page(response, dataset)
    allow(Search::Solr).to receive(:get_by_uuid).and_return(response)
    visit solr_dataset_path(dataset.id, dataset.name)
  end

  def then_a_message_indicates_no_data_links_are_available
    expect(page).to have_css("h2", text: "Data links")
    expect(page).to have_content("This data hasn’t been released by the publisher.")
  end

  def and_a_not_released_label_is_displayed
    expect(page).to have_content("Availability: Not released")
  end
end
