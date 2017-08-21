require 'rails_helper'

feature 'Dataset page', elasticsearch: true do
  scenario 'Displays 404 page if a dataset does not exist' do
    visit '/dataset/does-not-exist'

    expect(page.status_code).to eq(404)
    expect(page).to have_content('Page not found')
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
      ID_1 = 1
      ID_2 = 2
      TITLE_1 = '1 Data Set'
      TITLE_2 = '2 Data Set'
      SLUG_1 = 'first-dataset-data'
      SLUG_2 = 'second-dataset-data'

      first_dataset = DatasetBuilder.new
                        .with_title(TITLE_1)
                        .with_name(SLUG_1)
                        .with_datafiles(DATA_FILES_WITH_START_AND_ENDDATE)
                        .build

      second_dataset = DatasetBuilder.new
                         .with_title(TITLE_2)
                         .with_name(SLUG_2)
                         .with_datafiles(DATA_FILES_WITH_START_AND_ENDDATE)
                         .build

      index_data_with_id(first_dataset, ID_1)
      index_data_with_id(second_dataset, ID_2)

      refresh_index

      visit("/dataset/#{SLUG_1}")

      expect(page).to have_content('Related datasets')
      expect(page).to have_content(TITLE_2)
    end

    fscenario 'displays filtered related datasets if filters form part of search query' do
      ID_1 = 1
      ID_2 = 2
      ID_3 = 3
      TITLE_1 = 'First Dataset Data'
      TITLE_2 = 'Second Dataset Data'
      TITLE_3 = 'Completely unrelated'
      SLUG_1 = 'first-dataset-data'
      SLUG_2 = 'second-dataset-data'
      SLUG_3 = 'completely-unrelated'
      LONDON = 'London'
      AUCKLAND = 'Auckland'

      first_dataset = DatasetBuilder.new
                        .with_title(TITLE_1)
                        .with_name(SLUG_1)
                        .with_location(LONDON)
                        .with_datafiles(DATA_FILES_WITH_START_AND_ENDDATE)
                        .build

      second_dataset = DatasetBuilder.new
                         .with_title(TITLE_2)
                         .with_name(SLUG_2)
                         .with_datafiles(DATA_FILES_WITH_START_AND_ENDDATE)
                         .with_location(LONDON)
                         .build

      third_dataset = DatasetBuilder.new
                        .with_title(TITLE_3)
                        .with_name(SLUG_3)
                        .with_datafiles(DATA_FILES_WITH_START_AND_ENDDATE)
                        .with_summary('Nothing')
                        .with_description('Nothing')
                        .with_location(AUCKLAND)
                        .with_publisher('Unrelated publisher')
                        .build

      index_data_with_id(first_dataset, ID_1)
      index_data_with_id(second_dataset, ID_2)
      index_data_with_id(third_dataset, ID_3)

      refresh_index

      visit("/dataset/#{SLUG_1}")

      expect(page).to have_content('Related datasets')
      expect(page).to have_content(TITLE_2)
      expect(page).to_not have_content(TITLE_3)
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
