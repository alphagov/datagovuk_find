require 'rails_helper'

feature 'Dataset page', elasticsearch: true do
  scenario 'Displays 404 page if a dataset does not exist' do
    visit '/dataset/does-not-exist'

    expect(page.status_code).to eq(404)
    expect(page).to have_content('Not found')
  end

  feature 'Meta data' do
    scenario 'Display a location if there is one' do
      dataset = DatasetBuilder.new
                    .build

      index_and_visit(dataset)

      expect(page).to have_content('Geographical area: London Southwark')
    end
  end

  feature 'Datalinks' do
    scenario 'displays if required fields present' do
      dataset = DatasetBuilder.new
                    .with_datafiles(DATA_FILES_WITH_START_AND_ENDDATE)
                    .build

      index_and_visit(dataset)

      expect(page).to have_css('h2', text: 'Data links')
    end

    scenario 'do not display if datafiles are not present' do
      dataset = DatasetBuilder.new
                    .build

      index_and_visit(dataset)

      expect(page).to_not have_css('h2', text: 'Data links')
    end

    scenario 'display if some information is missing' do
      dataset = DatasetBuilder.new
                    .with_datafiles(DATAFILES_WITHOUT_START_AND_ENDDATE)
                    .build

      index_and_visit(dataset)

      expect(page).to have_css('h2', text: 'Data links')
    end
  end

  feature 'Related datasets' do
    scenario 'displays related datasets if there is a match' do
      first_id = 1
      second_id = 2
      first_dataset_title = '1 Data Set'
      first_dataset_slug = 'first-dataset-data'
      second_dataset_title = '2 Data Set'
      second_dataset_slug = 'second-dataset-data'

      first_dataset = DatasetBuilder.new
                          .with_title(first_dataset_title)
                          .with_name(first_dataset_slug)
                          .with_datafiles(DATA_FILES_WITH_START_AND_ENDDATE)
                          .build

      second_dataset = DatasetBuilder.new
                          .with_title(second_dataset_title)
                          .with_name(second_dataset_slug)
                          .with_datafiles(DATA_FILES_WITH_START_AND_ENDDATE)
                          .build

      index_data_with_id(first_dataset, first_id)
      index_data_with_id(second_dataset, second_id)

      refresh_index

      visit("/dataset/#{first_dataset_slug}")

      expect(page).to have_content('Related datasets')
      expect(page).to have_content(second_dataset_title)
    end

    scenario 'does not display if related datasets is empty' do
      allow(Dataset).to receive(:related).and_return([])

      dataset = DatasetBuilder.new
                    .with_datafiles(DATA_FILES_WITH_START_AND_ENDDATE)
                    .build

      index_and_visit(dataset)

      expect(page).to_not have_css('h3', text: 'Related datasets')
    end
  end

  feature 'Additional info' do
    scenario 'Is displayed if available' do
      notes = 'Some very interesting notes'
      dataset = DatasetBuilder.new
                    .with_datafiles(DATA_FILES_WITH_START_AND_ENDDATE)
                    .with_notes(notes)
                    .build

      index_and_visit(dataset)

      expect(page).to have_css('h2', text: 'Additional information')
      expect(page).to have_content(notes)
    end

    scenario 'Is not displayed if not available' do
      dataset = DatasetBuilder.new
                    .with_datafiles(DATA_FILES_WITH_START_AND_ENDDATE)
                    .build

      index_and_visit(dataset)

      expect(page).to_not have_css('h2', text: 'Additional information')
    end
  end

  feature 'Contact' do
    scenario 'Is displayed if available' do
      contact_email = 'contact@somewhere.com'
      dataset = DatasetBuilder.new
                    .with_contact_email(contact_email)
                    .with_datafiles(DATA_FILES_WITH_START_AND_ENDDATE)
                    .build

      index_and_visit(dataset)

      expect(page).to have_css('h2', text: 'Contact')
      expect(page).to have_css('a', text: contact_email)
    end

    scenario 'Is not displayed if not available' do
      dataset = DatasetBuilder.new
                    .with_datafiles(DATA_FILES_WITH_START_AND_ENDDATE)
                    .build

      index_and_visit(dataset)

      expect(page).to_not have_css('h2', text: 'Contact')
    end
  end

  def index_data_with_id(data, id)
    ELASTIC.index index: INDEX, type: 'dataset', id: id, body: data
  end
end
