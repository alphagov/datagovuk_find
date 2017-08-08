require 'rails_helper'

describe DatasetsHelper, type: :helper do
  it 'Should group time series data by year' do
    expect(helper.group_by_year(UNFORMATTED_DATASETS_MULTIYEAR)).to eql FORMATTED_DATASETS
  end

  it 'should return true if the dataset has data files from from more than one year' do
    expect(helper.timeseries_data?(UNFORMATTED_DATASETS_MULTIYEAR)).to be true
  end

  it 'should return false if the dataset has data files from the same year' do
    expect(helper.timeseries_data?(UNFORMATTED_DATASETS_SINGLEYEAR)).to be false
  end
end
