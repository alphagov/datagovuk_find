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

  it 'returns :html if datafile is a webpage' do
    expect(helper.link_type(HTML_DATAFILE)).to be :html
  end

  it 'returns :csv if datafile is csv' do
    expect(helper.link_type(CSV_DATAFILE)).to be :csv
  end

  it 'returns :no_preview if datafile format is unknown' do
    expect(helper.link_type(NO_FORMAT_DATAFILE)).to be :no_preview
  end

end
