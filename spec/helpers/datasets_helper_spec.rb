require 'rails_helper'

# The dataset objects used below are defined in support/dataset_spec_builder.rb

describe DatasetsHelper, type: :helper do
  it 'groups time series data by year' do
    expect(helper.group_by_year(UNFORMATTED_DATASETS_MULTIYEAR)).to eql FORMATTED_DATASETS
  end

  it 'returns true if the dataset has data files from from more than one year' do
    expect(helper.timeseries_data?(UNFORMATTED_DATASETS_MULTIYEAR)).to be true
  end

  it 'returns false if the dataset has data files from the same year' do
    expect(helper.timeseries_data?(UNFORMATTED_DATASETS_SINGLEYEAR)).to be false
  end

  it 'returns html if datafile is a webpage' do
    expect(helper.link_type(DATA_FILES_WITH_START_AND_ENDDATE[0])).to be :html
  end

  it 'returns :no_preview if datafile has nil or blank format and no preview' do
    stub_for_no_data_preview

    expect(helper.link_type(DATAFILES_WITHOUT_START_AND_ENDDATE[0])).to be :no_preview
  end

  it 'returns no_preview if datafile has no preview' do
    stub_for_no_data_preview

    expect(helper.link_type(DATA_FILES_WITH_START_AND_ENDDATE[1])).to be :no_preview
  end

  it 'returns preview if datafile has a preview' do
    stub_for_existing_data_preview

    expect(helper.link_type(CSV_DATAFILE)).to be :preview
  end

  def stub_for_no_data_preview
    stub_request(:any, FETCH_PREVIEW_URL).
      to_return(status: 200)
  end

  def stub_for_existing_data_preview
    stub_request(:any, FETCH_PREVIEW_URL).
      to_return(status: 200, body: [{data: 'blah'}])
  end

end
