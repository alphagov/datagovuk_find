require 'rails_helper'

feature 'Dataset page', elasticsearch: true do
  scenario 'Displays 404 page if a dataset does not exist' do
    visit '/dataset/invalid-uuid/invalid-slug'

    expect(page.status_code).to eq(404)
    expect(page).to have_content('Page not found')
  end

  feature 'Licence information' do
    scenario 'Link to Open Government Licence information' do
      dataset = DatasetBuilder
                  .new
                  .with_licence('uk-ogl')
                  .build

      index_and_visit(dataset)

      expect(page)
        .to have_css('meta[name="dc:rights"][content="Open Government Licence"]',
                     visible: false)

      within('section.meta-data') do
        expect(page)
          .to have_link('Open Government Licence',
                        href: 'http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/')
      end
    end

    scenario 'Link to Open Government Licence with additional information' do
      dataset = DatasetBuilder
                  .new
                  .with_licence('uk-ogl')
                  .with_licence_custom('Special case')
                  .build

      index_and_visit(dataset)

      expect(page)
        .to have_css('meta[name="dc:rights"][content="Open Government Licence"]',
                     visible: false)

      within('section.meta-data') do
        expect(page)
          .to have_link('Open Government Licence',
                        href: 'http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/')

        expect(page)
          .to have_link('View licence information',
                        href: '#licence-info')
      end

      within('section.dgu-licence-info') do
        expect(page).to have_content('Special case')
      end
    end

    scenario 'Link to Creative Commons CCZero information' do
      dataset = DatasetBuilder
                  .new
                  .with_licence('other')
                  .with_licence_other('cc-zero')
                  .build

      index_and_visit(dataset)

      expect(page)
        .to have_css('meta[name="dc:rights"][content="Creative Commons CCZero"]',
                     visible: false)

      within('section.meta-data') do
        expect(page)
          .to have_link('Creative Commons CCZero',
                        href: 'http://www.opendefinition.org/licenses/cc-zero')
      end
    end

    scenario 'Licence information' do
      dataset = DatasetBuilder
                  .new
                  .with_licence('no-licence')
                  .with_licence_custom('Special licence')
                  .build

      index_and_visit(dataset)

      expect(page)
        .to have_css('meta[name="dc:rights"][content="Other"]',
                     visible: false)

      within('section.meta-data') do
        expect(page)
          .to have_link('View licence information',
                        href: '#licence-info')
      end

      within('section.dgu-licence-info') do
        expect(page).to have_content('Special licence')
      end
    end

    scenario 'Explicit licence information' do
      dataset = DatasetBuilder
                  .new
                  .with_licence_code('example-1.1')
                  .with_licence_title('Example Open License 1.1')
                  .with_licence_url('https://opensource.org/licenses/Example-1.1')
                  .build

      index_and_visit(dataset)

      expect(page)
        .to have_css('meta[name="dc:rights"][content="Example Open License 1.1"]',
                     visible: false)

      within('section.meta-data') do
        expect(page)
          .to have_link('Example Open License 1.1',
                        href: 'https://opensource.org/licenses/Example-1.1')
      end
    end

    scenario 'Explicit licence information with additional license information' do
      dataset = DatasetBuilder
                  .new
                  .with_licence_code('feature-spec-2.1')
                  .with_licence_title('Feature Spec Open License 2.1')
                  .with_licence_url('https://opensource.org/licenses/Feature-Spec-2.1')
                  .with_licence_custom('For feature specs only.')
                  .build

      index_and_visit(dataset)

      expect(page)
        .to have_css('meta[name="dc:rights"][content="Feature Spec Open License 2.1"]',
                     visible: false)

      within('section.meta-data') do
        expect(page)
          .to have_link('Feature Spec Open License 2.1',
                        href: 'https://opensource.org/licenses/Feature-Spec-2.1')

        expect(page)
          .to have_link('View licence information',
                        href: '#licence-info')
      end

      within('section.dgu-licence-info') do
        expect(page).to have_content('For feature specs only.')
      end
    end
  end

  feature 'Map preview links' do
    scenario 'WMS Resources have a link to map preview if we have inspire metadata' do
      dataset = DatasetBuilder
        .new
        .with_datafiles(GEO_DATAFILES.map { |f| Datafile.new(f) })
        .with_inspire_metadata(
          'bbox_north_lat' => '1.0',
          'bbox_east_long' => '1.0',
          'bbox_south_lat' => '2.0',
          'bbox_west_long' => '2.0',
        )
        .build
      index_and_visit(dataset)

      expect(page).to have_content('Preview on map')
    end

    scenario 'WMS Resources have no link to map preview if we have no inspire metadata' do
      dataset = DatasetBuilder
        .new
        .with_datafiles(GEO_DATAFILES.map { |f| Datafile.new(f) })
        .build
      index_and_visit(dataset)

      expect(page).not_to have_content('Preview on map')
    end
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

    scenario 'Last Updated field displays public_updated_at' do
      dataset = DatasetBuilder.new.build
      index_and_visit(dataset)
      expect(page).to have_content("Last updated: #{dataset['public_updated_at']}")
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

      expect(page).to have_content("This data hasn’t been released by the publisher.")
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
        title1 = '1 Data Set'
        @title2 = '2 Data Set'
        slug1 = 'first-dataset-data'
        slug2 = 'second-dataset-data'

        @first_dataset = DatasetBuilder.new
          .with_title(title1)
          .with_name(slug1)
          .with_datafiles(DATA_FILES_WITH_START_AND_ENDDATE)
          .build

        second_dataset = DatasetBuilder.new
          .with_title(@title2)
          .with_name(slug2)
          .with_datafiles(DATA_FILES_WITH_START_AND_ENDDATE)
          .build

        index(@first_dataset, second_dataset)
        refresh_index

        visit dataset_path(@first_dataset[:uuid], @first_dataset[:name])
      end

      scenario 'displays related datasets if there is a match' do
        expect(page).to have_content('Related datasets')
        expect(page).to have_content(@title2)
      end

      scenario 'displays link to publisher\'s datasets' do
        expect(page).to have_content('More from this publisher')
        expect(page).to have_css('a', text: "All datasets from #{@first_dataset[:organisation][:title]}")
      end
    end

    scenario 'displays filtered related datasets if filters form part of search query' do
      title1 = 'First Dataset Data'
      title2 = 'Second Dataset Data'
      title3 = 'Completely unrelated'
      slug1 = 'first-dataset-data'
      slug2 = 'second-dataset-data'
      slug3 = 'completely-unrelated'
      london = 'London'
      auckland = 'Auckland'

      first_dataset = DatasetBuilder.new
        .with_title(title1)
        .with_name(slug1)
        .with_location(london)
        .with_datafiles(DATA_FILES_WITH_START_AND_ENDDATE)
        .build

      second_dataset = DatasetBuilder.new
        .with_title(title2)
        .with_name(slug2)
        .with_datafiles(DATA_FILES_WITH_START_AND_ENDDATE)
        .with_location(london)
        .build

      third_dataset = DatasetBuilder.new
        .with_title(title3)
        .with_name(slug3)
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
      expect(page).to have_content(title2)
      expect(page).to_not have_content(title3)
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
        datafiles.push(
          'id' => i,
          'url' => "http://datafile-url",
          'start_date' => nil,
          'end_date' => nil,
          'created_at' => '2017-07-31T14:40:57.528Z',
          'updated_at' => '2017-08-31T14:40:57.528Z'
        )
      end

      datafiles
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
        Time.parse(timeseries_and_non_timeseries[1][:start_date]).year.to_s,
        Time.parse(timeseries_and_non_timeseries[0][:start_date]).year.to_s
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

  feature 'not released label' do
    scenario 'Not released label is not shown where there are files' do
      dataset = DatasetBuilder
                  .new
                  .with_legacy_name('abc123')
                  .with_datafiles(DATA_FILES_WITH_START_AND_ENDDATE)
                  .build

      index_and_visit(dataset)

      expect(page).to have_no_content('Not released')
    end

    scenario 'Not released is not shown where there are docs' do
      dataset = DatasetBuilder
                  .new
                  .with_legacy_name('abc123')
                  .with_docs([HTML_DATAFILE])
                  .build

      index_and_visit(dataset)

      expect(page).to have_no_content('Not released')
    end

    scenario 'Not released is shown when there are no docs and no files' do
      dataset = DatasetBuilder
                  .new
                  .with_legacy_name('abc123')
                  .build

      index_and_visit(dataset)
      expect(page).to have_content('Not released')
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
    scenario 'cannot edit harvested dataset' do
      dataset = DatasetBuilder
                  .new
                  .with_legacy_name('abc123')
                  .with_harvested(true)
                  .build

      index_and_visit(dataset)

      expect(page).to_not have_link('Sign in', href: 'https://data.gov.uk/dataset/edit/abc123')
    end

    scenario 'edit released dataset link with datafile' do
      dataset = DatasetBuilder
                  .new
                  .with_legacy_name('abc123')
                  .with_datafiles(DATA_FILES_WITH_START_AND_ENDDATE)
                  .build

      index_and_visit(dataset)

      expect(page).to have_link('Sign in', href: 'https://data.gov.uk/dataset/edit/abc123')
    end

    scenario 'edit released dataset link with doc' do
      dataset = DatasetBuilder
                  .new
                  .with_legacy_name('abc123')
                  .with_docs([HTML_DATAFILE])
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
      expect(page).to have_link('Sign in', href: 'https://data.gov.uk/dataset/edit/abc123')
    end
  end
end
