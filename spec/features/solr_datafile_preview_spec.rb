require "rails_helper"

RSpec.feature "Solr Datafile preview", type: :feature do
  background do
    given_an_organisation_exists
  end

  scenario "User views a XML datafile preview page" do
    given_a_dataset_with_datafiles_exists
    when_i_visit_xml_datafile_preview_page(@dataset)
    then_i_see_information_that_preview_is_not_available
  end

  def given_an_organisation_exists
    org_response = JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_organisation.json").to_s))
    allow(Search::Solr).to receive(:get_organisation).and_return(org_response)
  end

  def given_a_dataset_with_datafiles_exists
    response = JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_dataset.json").to_s))
    params = response["response"]["docs"].first
    @dataset = SolrDataset.new(params)
    allow(SolrDataset).to receive(:get_by_uuid).and_return(@dataset)
  end

  def when_i_visit_xml_datafile_preview_page(dataset)
    visit solr_datafile_preview_path(dataset.uuid, dataset.name, dataset.datafiles.first.uuid)
  end

  def then_i_see_information_that_preview_is_not_available
    expect(page).to have_content("Currently there is no preview available")
  end
end
