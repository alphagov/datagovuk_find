require 'rails_helper'

feature 'Dataset page', elasticsearch: true do
  scenario 'Displays 404 page if a dataset does not exist' do
    visit '/dataset/invalid-uuid/invalid-slug'

    expect(page.status_code).to eq(404)
    expect(page).to have_content('Page not found')
  end

  feature 'Meta data' do
    before(:each) do
      dataset = DatasetBuilder.new.build
      index_and_visit(dataset)
    end

    scenario 'Display the topic if there is one' do
      expect(page).to have_content('Topic: Government')
    end

    scenario 'Do not display the topic if information missing' do
      dataset = DatasetBuilder.new.build
      dataset['topic'] = nil

      index_and_visit(dataset)

      expect(page).to have_content('Topic: Not added')
    end

    context 'When a dataset has no datafiles' do
      it 'Last Updated field displays last_updated_at' do
        dataset = DatasetBuilder.new.build
        index_and_visit(dataset)
        expect(page).to have_content("Last updated: #{dataset['last_updated_at']}")
      end
    end

    context 'When a dataset has datafiles' do
      it 'Last Updated field is the most recent datafiles creation date' do
        dataset = DatasetBuilder.new
          .with_datafiles(DATA_FILES_WITH_START_AND_ENDDATE)
          .build
        index_and_visit(dataset)
        datafiles = dataset[:datafiles]
        last = datafiles.sort_by{ |datafile| datafile[:created_at]}.last
        date = Time.parse(last["created_at"]).strftime("%d %B %Y")
        expect(page).to have_content("Last updated: #{date}")
      end
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

    scenario 'datafiles are not present' do
      dataset = DatasetBuilder.new
        .build

      index_and_visit(dataset)

      expect(page).to have_content("This data hasn't been released by the publisher.")
    end

    scenario 'display if some information is missing' do
      dataset = DatasetBuilder.new
        .with_datafiles(DATAFILES_WITHOUT_START_AND_ENDDATE)
        .build

      index_and_visit(dataset)

      expect(page).to have_css('h2', text: 'Data links')
    end
  end

  feature 'Side bar content' do
    context 'Related content and publisher datasets' do
      before do
        title_1 = '1 Data Set'
        @title_2 = '2 Data Set'
        slug_1 = 'first-dataset-data'
        slug_2 = 'second-dataset-data'

        @first_dataset = DatasetBuilder.new
          .with_title(title_1)
          .with_name(slug_1)
          .with_datafiles(DATA_FILES_WITH_START_AND_ENDDATE)
          .build

        second_dataset = DatasetBuilder.new
          .with_title(@title_2)
          .with_name(slug_2)
          .with_datafiles(DATA_FILES_WITH_START_AND_ENDDATE)
          .build

        index(@first_dataset, second_dataset)
        refresh_index

        visit dataset_path(@first_dataset[:uuid], @first_dataset[:name])
      end

      scenario 'displays related datasets if there is a match' do
        expect(page).to have_content('Related datasets')
        expect(page).to have_content(@title_2)
      end

      scenario 'displays link to publisher\'s datasets' do
        expect(page).to have_content('More from this publisher')
        expect(page).to have_css('a', text: "All datasets from #{@first_dataset[:organisation][:title]}")
      end
    end

    scenario 'displays filtered related datasets if filters form part of search query' do
      title_1 = 'First Dataset Data'
      title_2 = 'Second Dataset Data'
      title_3 = 'Completely unrelated'
      slug_1 = 'first-dataset-data'
      slug_2 = 'second-dataset-data'
      slug_3 = 'completely-unrelated'
      london = 'London'
      auckland = 'Auckland'

      first_dataset = DatasetBuilder.new
        .with_title(title_1)
        .with_name(slug_1)
        .with_location(london)
        .with_datafiles(DATA_FILES_WITH_START_AND_ENDDATE)
        .build

      second_dataset = DatasetBuilder.new
        .with_title(title_2)
        .with_name(slug_2)
        .with_datafiles(DATA_FILES_WITH_START_AND_ENDDATE)
        .with_location(london)
        .build

      third_dataset = DatasetBuilder.new
        .with_title(title_3)
        .with_name(slug_3)
        .with_datafiles(DATA_FILES_WITH_START_AND_ENDDATE)
        .with_summary('Nothing')
        .with_description('Nothing')
        .with_location(auckland)
        .with_publisher('Unrelated publisher')
        .build

      index(first_dataset, second_dataset, third_dataset)

      refresh_index

      visit dataset_path(first_dataset[:uuid], first_dataset[:name])

      expect(page).to have_content('Related datasets')
      expect(page).to have_content(title_2)
      expect(page).to_not have_content(title_3)
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

  feature 'Displaying datasets', js: true do
    scenario 'Show more and show less' do
      DATAFILES = create_datafiles(20)
      dataset = DatasetBuilder.new
        .with_datafiles(DATAFILES)
        .build

      index_and_visit(dataset)

      expect(page).to have_css('js-show-more-datafiles', count: 0)
      expect(page).to have_css('.dgu-datafile', count: 5)
      expect(page).to have_css('.show-toggle', text: 'Show more')

      find('.show-toggle').click

      expect(page).to have_css('.dgu-datafile', count: 20)
      expect(page).to have_css('.show-toggle', text: 'Show less')
    end

    def create_datafiles(count)
      datafiles = []

      count.times do |i|
        datafiles.push({
          'id' => i,
          'url' => "http://datafile-url",
          'start_date' => nil,
          'end_date' => nil,
          'created_at' => '2017-07-31T14:40:57.528Z',
          'updated_at' => '2017-08-31T14:40:57.528Z'
        })
      end

      return datafiles
    end
  end

  feature 'Datafiles' do
    scenario 'are grouped by year when they contain timeseries datafiles' do
      timeseries_and_non_timeseries = [
        {
          id: 1,
          url: "http://www.foobar.com",
          name: "Datafile 1",
          start_date: "2000/01/01",
          end_date: "2000/12/12",
          created_at: "1999/12/12",
          updated_at: "2000/01/01"
        },
        {
          id: 2,
          url: "http://www.foobar.com",
          name: "Datafile 2",
          start_date: "2001/01/01",
          end_date: "2001/12/12",
          created_at: "2000/12/12",
          updated_at: "2001/01/01"
        },
        {
          id: 3,
          url: "http://www.foobar.com",
          name: "Datafile 3",
          start_date: "2001/01/01",
          end_date: "2001/12/12",
          created_at: "2000/12/12",
          updated_at: "2001/01/01"
        },
        {
          id: 4,
          url: "http://www.foobar.com",
          name: "Datafile 4",
          start_date: nil,
          end_date: nil,
          created_at: "2000/12/12",
          updated_at: "2001/01/01"
        }
      ]

      dataset = DatasetBuilder.new
        .with_datafiles(timeseries_and_non_timeseries)
        .build

      index_and_visit(dataset)
      expect(page).to have_css(".dgu-datafiles__year", count: 2)

      correct_order = [
        "#{Time.parse(timeseries_and_non_timeseries[1][:start_date]).year}",
        "#{Time.parse(timeseries_and_non_timeseries[0][:start_date]).year}"
      ]
      actual_order = all('button.dgu-datafiles__year').map(&:text)

      expect(actual_order).to eq correct_order
    end

    scenario 'are not grouped when they contain non timeseries datafiles' do
      non_timeseries_data_files = [
        {
          id: 1,
          url: "http://www.foobar.com",
          name: "Datafile 1",
          start_date: nil,
          end_date: nil,
          created_at: "1999/12/12",
          updated_at: "2000/01/01"
        },
        {
          id: 2,
          url: "http://www.foobar.com",
          name: "Datafile 2",
          start_date: nil,
          end_date: nil,
          created_at: "2000/12/12",
          updated_at: "2001/01/01"
        },
        {
          id: 3,
          url: "http://www.foobar.com",
          name: "Datafile 3",
          start_date: nil,
          end_date: nil,
          created_at: "2000/12/12",
          updated_at: "2001/01/01"
        }
      ]

      dataset = DatasetBuilder.new
        .with_datafiles(non_timeseries_data_files)
        .build

      index_and_visit(dataset)

      expect(page).to have_css(".dgu-datalinks__year", count: 0)
    end
  end

  feature 'contact instructions' do
    scenario 'publisher contact details exist' do
      dataset = DatasetBuilder.new.build
      dataset[:contact_email] = "foo@bar.com"
      index_and_visit(dataset)
      expect(page).to have_content("Contact the publisher for more information.")
    end

    scenario 'publisher contact details do not exist' do
      dataset = DatasetBuilder.new.build
      index_and_visit(dataset)
      expect(page).to have_content("Contact the team on data.gov.uk/support if you have any questions.")
    end
  end

  feature 'publisher edit link' do
    scenario 'edit released dataset link' do
      dataset = DatasetBuilder
                  .new
                  .with_legacy_name('abc123')
                  .with_datafiles(DATA_FILES_WITH_START_AND_ENDDATE)
                  .build

      index_and_visit(dataset)

      expect(page).to have_link('Sign in', href: 'https://data.gov.uk/dataset/edit/abc123')
    end

    scenario 'edit not released dataset link' do
      dataset = DatasetBuilder
                  .new
                  .with_legacy_name('abc123')
                  .build

      index_and_visit(dataset)

      expect(page).to have_link('Sign in', href: 'https://data.gov.uk/unpublished/edit-item/abc123')
    end
  end
end
