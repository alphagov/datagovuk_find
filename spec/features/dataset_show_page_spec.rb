require 'rails_helper'

describe 'Dataset page', elasticsearch: true do
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

  describe 'Datafiles are present' do
    describe 'Data links'

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

    describe 'Feedback' do
      xit 'Is displayed if available' do
        dataset = create_dataset(DATA_TITLE, 'annual', DATA_FILES_WITH_ENDDATE)
        index_and_visit(dataset)
        expect(page).to have_content('Was this page useful for you?')
      end
    end
  end

  describe 'Datafiles are not present' do
    context 'Sections' do
      SECTIONS = [
          'Data links',
          'Additional information',
          'Supporting documents',
          'Contact'
          # 'Feedback'
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
end
