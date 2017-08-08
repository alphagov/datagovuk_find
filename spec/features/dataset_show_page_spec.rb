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

  describe 'Meta data' do
    it 'displays a location if there is one' do
      dataset = create_dataset(DATA_TITLE)
      index_and_visit(dataset)
      expect(page).to have_content('Geographical area: London Southwark')
    end
  end

  describe 'Related datasets' do
    it 'displays related datasets if there is a match' do
      first_id = 1
      second_id = 2
      first_dataset = create_dataset('First dataset data','annual', DATA_FILES_WITH_ENDDATE)
      second_dataset = create_dataset('Second dataset data', 'annual', DATA_FILES_WITH_ENDDATE)

      index_data_with_id(first_dataset,first_id)
      index_data_with_id(second_dataset,second_id)

      refresh_index

      visit("/dataset/#{first_id}")

      expect(page).to have_content('Second dataset data')

    end
  end

  scenario 'Datafiles are present' do
    describe 'Additional info' do
      it 'Is displayed if available' do
        notes = 'Some very interesting notes'
        dataset = create_dataset(DATA_TITLE, 'annual', DATA_FILES_WITH_ENDDATE, notes)
        index_and_visit(dataset)
        expect(page).to have_content(notes)
      end
    end

    describe 'Publisher' do
      it 'Is displayed if available' do
        dataset = create_dataset(DATA_TITLE, 'annual', DATA_FILES_WITH_ENDDATE)
        index_and_visit(dataset)
        publisher = 'Ministry of Defence'
        expect(page).to have_content(publisher)
      end
    end
  end

  scenario 'Datafiles are not present' do
    describe 'Sections' do
      SECTIONS = [
          'Data links',
          'Additional information',
          'Supporting documents',
          'Contact'
      ]

      before(:each) do
        dataset = create_dataset(DATA_TITLE)
        index_and_visit(dataset)
      end


      SECTIONS.each do |section|
        it "does not display the section #{section}" do
          expect(page).to have_no_content(section)
        end
      end
    end
  end

  def index_data_with_id(data, id)
    ELASTIC.index index: INDEX, type: 'dataset', id: id, body: data
  end
end
