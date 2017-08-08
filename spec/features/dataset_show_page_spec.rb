require 'rails_helper'

feature 'Dataset page', elasticsearch: true do
  DATA_TITLE = 'Some very interesting data'

  DATA_FILES_WITH_ENDDATE = [
      {'id' => 1,
       'name' => 'I have no end date',
       'url' => 'https://good_data.co.uk',
       'start_date' => '1/1/15',
       'end_date' => nil,
       'updated_at' => '2016-08-31T14:40:57.528Z'
      },
      {'id' => 2,
       'name' => 'I have an end date',
       'url' => 'https://good_data.co.uk',
       'start_date' => '1/1/15',
       'end_date' => '24/03/2018',
       'updated_at' => '2016-08-31T14:40:57.528Z'
      },
      {'id' => 3,
       'name' => 'I have an end date',
       'url' => 'https://good_data.co.uk',
       'start_date' => '1/1/15',
       'end_date' => '01/12/2018',
       'updated_at' => '2016-08-31T14:40:57.528Z'
      }
  ]

  DATAFILES_WITH_NO_ENDDATE = [
      {'id' => 1,
       'name' => 'I have no end date',
       'url' => 'https://good_data.co.uk',
       'start_date' => '1/1/15',
       'end_date' => nil,
       'updated_at' => '2016-08-31T14:40:57.528Z'
      },
      {'id' => 2,
       'name' => 'I have an end date',
       'url' => 'https://good_data.co.uk',
       'start_date' => '1/1/15',
       'end_date' => nil,
       'updated_at' => '2016-08-31T14:40:57.528Z'
      }]

  feature 'Meta data' do
    scenario 'displays a location if there is one' do
      dataset = DatasetBuilder.new
                    .with_title(DATA_TITLE)
                    .build

      index_and_visit(dataset)

      expect(page).to have_content('Geographical area: London Southwark')
    end
  end

  feature 'Related datasets' do
    scenario 'displays related datasets if there is a match' do
      first_id = 1
      second_id = 2
      first_dataset_title = 'First dataset title'
      second_dataset_title = 'Second dataset data'

      first_dataset = DatasetBuilder.new
                          .with_title(first_dataset_title)
                          .with_datafiles(DATA_FILES_WITH_ENDDATE)
                          .build

      second_dataset = DatasetBuilder.new
                          .with_title(second_dataset_title)
                          .with_datafiles(DATA_FILES_WITH_ENDDATE)
                          .build

      index_data_with_id(first_dataset, first_id)
      index_data_with_id(second_dataset, second_id)

      refresh_index

      visit("/dataset/#{first_id}")

      expect(page).to have_content(second_dataset_title)

    end
  end

  feature 'Additional info' do
    scenario 'Is displayed if available' do
      notes = 'Some very interesting notes'
      dataset = DatasetBuilder.new
                    .with_title(DATA_TITLE)
                    .with_datafiles(DATA_FILES_WITH_ENDDATE)
                    .with_notes(notes)
                    .build

      index_and_visit(dataset)

      expect(page).to have_content(notes)
    end
  end

  feature 'Publisher' do
    scenario 'Is displayed if available' do
      publisher = 'Ministry of Defence'
      dataset = DatasetBuilder.new
                    .with_title(DATA_TITLE)
                    .with_datafiles(DATA_FILES_WITH_ENDDATE)
                    .build

      index_and_visit(dataset)

      expect(page).to have_content(publisher)
    end
  end

  def index_data_with_id(data, id)
    ELASTIC.index index: INDEX, type: 'dataset', id: id, body: data
  end
end
