require 'rails_helper'

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

  it 'displays view if the datafile is html' do
    HTML_DATAFILE = DATA_FILES_WITH_START_AND_ENDDATE[0]
    expect(helper.format_button(HTML_DATAFILE)).to eql 'View'
  end

  it 'displays download if the datafile is not HTML' do
    CSV_DATAFILE = DATA_FILES_WITH_START_AND_ENDDATE[1]
    expect(helper.format_button(CSV_DATAFILE)).to eql 'Download'
  end
end
