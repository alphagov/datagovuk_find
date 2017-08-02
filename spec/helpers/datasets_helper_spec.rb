require 'rails_helper'

describe DatasetsHelper, type: :helper do
  it 'Should group time series data by year' do

    unformattedDatasets = [
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

    formattedDatasets = {
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

    expect(helper.group_by_year(unformattedDatasets)).to eql formattedDatasets
  end
end
