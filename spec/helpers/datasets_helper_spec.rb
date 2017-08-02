require 'rails_helper'

describe DatasetsHelper, type: :helper do
  UNFORMATTED_DATASETS_MULTIYEAR = [
      {'id' => 1,
       'name' => 'Dataset 1',
       'url' => 'https://good_data.co.uk',
       'start_date' => '2017-09-24',
       'end_date' => nil,
       'updated_at' => '2017-08-31T14:40:57.528Z'
      },
      {'id' => 2,
       'name' => 'Dataset 2',
       'url' => 'https://good_data.co.uk',
       'start_date' => '2015-09-25',
       'end_date' => nil,
       'updated_at' => '2015-10-31T14:40:57.528Z'
      },
      {'id' => 3,
       'name' => 'Dataset 3',
       'url' => 'https://good_data.co.uk',
       'start_date' => '2015-09-24',
       'end_date' => nil,
       'updated_at' => '2015-08-31T14:40:57.528Z'
      }]

  UNFORMATTED_DATASETS_SINGLEYEAR = [
      {'id' => 1,
       'name' => 'Dataset 1',
       'url' => 'https://good_data.co.uk',
       'start_date' => '2017-09-24',
       'end_date' => nil,
       'updated_at' => '2017-08-31T14:40:57.528Z'
      },
      {'id' => 2,
       'name' => 'Dataset 2',
       'url' => 'https://good_data.co.uk',
       'start_date' => '2017-09-25',
       'end_date' => nil,
       'updated_at' => '2015-10-31T14:40:57.528Z'
      },
      {'id' => 3,
       'name' => 'Dataset 3',
       'url' => 'https://good_data.co.uk',
       'start_date' => '2017-09-24',
       'end_date' => nil,
       'updated_at' => '2015-08-31T14:40:57.528Z'
      }]


  FORMATTED_DATASETS = {
      '2017' => [{'id' => 1,
                  'name' => 'Dataset 1',
                  'url' => 'https://good_data.co.uk',
                  'start_date' => '2017-09-24',
                  'end_date' => nil,
                  'updated_at' => '2017-08-31T14:40:57.528Z',
                  'start_year' => '2017'
                 }],
      '2015' => [{'id' => 2,
                  'name' => 'Dataset 2',
                  'url' => 'https://good_data.co.uk',
                  'start_date' => '2015-09-25',
                  'end_date' => nil,
                  'updated_at' => '2015-10-31T14:40:57.528Z',
                  'start_year' => '2015'},
                 {'id' => 3,
                  'name' => 'Dataset 3',
                  'url' => 'https://good_data.co.uk',
                  'start_date' => '2015-09-24',
                  'end_date' => nil,
                  'updated_at' => '2015-08-31T14:40:57.528Z',
                  'start_year' => '2015'
                 }]
  }

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
