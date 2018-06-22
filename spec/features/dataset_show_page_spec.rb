require 'rails_helper'

RSpec.feature 'Dataset page', type: :feature, elasticsearch: true do
  scenario 'Displays 404 page if a dataset does not exist' do
    visit '/dataset/invalid-uuid/invalid-slug'

    expect(page.status_code).to eq(404)
    expect(page).to have_content('Page not found')
  end

  feature 'Licence information' do
    scenario 'Meta licence tag' do
      dataset = build :dataset, :with_ogl_licence
      index_and_visit(dataset)

      expect(page)
        .to have_css('meta[name="dc:rights"][content="Open Government Licence"]',
                     visible: false)
    end

    scenario 'Link to licence' do
      dataset = build :dataset, :with_ogl_licence
      index_and_visit(dataset)

      within('section.meta-data') do
        expect(page)
          .to have_link('Open Government Licence',
                        href: 'http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/')
      end
    end

    scenario 'Link to licence with additional info' do
      dataset = build :dataset, :with_ogl_licence,
                                licence_custom: 'Special case'

      index_and_visit(dataset)

      within('section.meta-data') do
        expect(page)
          .to have_link('View licence information',
                        href: '#licence-info')
      end

      within('section.dgu-licence-info') do
        expect(page).to have_content('Special case')
      end
    end

    scenario 'Link to custom licence (no title, no URL)' do
      dataset = build :dataset, :with_custom_licence
      index_and_visit(dataset)

      within('section.meta-data') do
        expect(page)
          .to have_content('Other Licence')

        expect(page)
          .to have_link('View licence information',
                        href: '#licence-info')
      end

      within('section.dgu-licence-info') do
        expect(page).to have_content('Special case')
      end
    end

    scenario 'Simple licence title (no URL)' do
      dataset = build :dataset, licence_title: 'My Licence'
      index_and_visit(dataset)

      within('section.meta-data') do
        expect(page)
          .to have_content('My Licence')
      end
    end

    scenario 'Link to URL licence without a title' do
      dataset = build :dataset, licence_url: 'http://licence.com'
      index_and_visit(dataset)

      within('section.meta-data') do
        expect(page)
          .to have_link('http://licence.com',
                        href: 'http://licence.com')
      end
    end

    scenario 'No licence' do
      dataset = build :dataset
      index_and_visit(dataset)

      within('section.meta-data') do
        expect(page)
          .to have_content('None')
      end
    end
  end

  feature 'Map preview links' do
    scenario 'WMS Resources have a link to map preview if we have inspire metadata' do
      dataset = build :dataset, :inspire, inspire_metadata: {}
      index_and_visit(dataset)
      expect(page).to have_content('Preview on map')
    end

    scenario 'WMS Resources have no link to map preview if we have no inspire metadata' do
      dataset = build :dataset
      index_and_visit(dataset)
      expect(page).not_to have_content('Preview on map')
    end
  end

  feature 'Meta data' do
    scenario 'Display the topic if there is one' do
      dataset = build :dataset, :with_topic
      index_and_visit(dataset)
      expect(page).to have_content('Topic: Government')
    end

    scenario 'Do not display the topic if information missing' do
      dataset = build :dataset
      index_and_visit(dataset)
      expect(page).to have_content('Topic: Not added')
    end

    scenario 'Last Updated field displays public_updated_at' do
      dataset = build :dataset
      time = Time.parse(dataset.public_updated_at)
      index_and_visit(dataset)
      expect(page).to have_content("Last updated: #{time.strftime('%d %B %Y')}")
    end
  end

  feature 'Datalinks' do
    let(:dataset) { build :dataset }

    scenario 'displays if required fields present' do
      dataset = build :dataset, datafiles: [build(:datafile, :raw, start_date: '01/01/2001')]
      index_and_visit(dataset)
      expect(page).to have_css('h2', text: 'Data links')
    end

    scenario 'datafiles are not present' do
      index_and_visit(dataset)
      expect(page).to have_content("This data hasn’t been released by the publisher.")
    end

    scenario 'display if some information is missing' do
      dataset = build :dataset, :with_datafile
      index_and_visit(dataset)
      expect(page).to have_css('h2', text: 'Data links')
    end
  end

  feature 'Side bar content' do
    let(:dataset1) { build :dataset, title: '1 Data Set' }
    let(:dataset2) { build :dataset, title: '2 Data Set' }
    let(:dataset3) { build :dataset, :unrelated }

    context 'Related content and publisher datasets' do
      before do
        index(dataset1, dataset2)
        refresh_index
        visit dataset_path(dataset1.uuid, dataset1.name)
      end

      scenario 'displays related datasets if there is a match' do
        expect(page).to have_content('Related datasets')
        expect(page).to have_content(dataset2.title)
      end

      scenario 'displays link to publisher\'s datasets' do
        expect(page).to have_content('More from this publisher')
        expect(page).to have_css('a', text: "All datasets from #{dataset1.organisation.title}")
      end
    end

    scenario 'displays filtered related datasets if filters form part of search query' do
      index(dataset1, dataset2, dataset3)
      refresh_index
      visit dataset_path(dataset1.uuid, dataset1.name)

      expect(page).to have_content('Related datasets')
      expect(page).to have_content(dataset2.title)
      expect(page).to_not have_content(dataset3.title)
    end

    scenario 'does not display if related datasets is empty' do
      allow(Dataset).to receive(:related).and_return([])
      index_and_visit(dataset1)
      expect(page).to_not have_css('h3', text: 'Related datasets')
    end
  end

  feature 'Additional info' do
    scenario 'Is displayed if available' do
      dataset = build :dataset
      index_and_visit(dataset)
      expect(page).to have_css('h2', text: 'Additional information')
      expect(page).to have_content(dataset.description)
    end

    scenario 'Contains a link to original INSPIRE XML' do
      dataset = build :dataset, :inspire
      index_and_visit(dataset)
      expect(page).to have_xpath("//a[@href='/api/2/rest/harvestobject/1234/xml']")
    end

    scenario 'Contains a link to HTML rendering of INSPIRE XML' do
      dataset = build :dataset, :inspire
      index_and_visit(dataset)
      expect(page).to have_xpath("//a[@href='/api/2/rest/harvestobject/1234/html']")
    end

    scenario 'Is not displayed if not available' do
      dataset = build :dataset, description: nil
      index_and_visit(dataset)
      expect(page).to_not have_css('h2', text: 'Additional information')
    end
  end

  feature 'Contact enquiries' do
    scenario 'Is not displayed if not available' do
      dataset = build :dataset
      index_and_visit(dataset)
      expect(page).to_not have_css('h2', text: 'Contact')
    end

    scenario 'Is displayed if available' do
      dataset = build :dataset, contact_name: 'Mr. Contact',
                                contact_email: 'mr.contact@example.com'

      index_and_visit(dataset)

      expect(page).to have_css('h2', text: 'Contact')
      expect(page).to have_css('h3', text: 'Enquiries')

      within('section.contact .enquiries') do
        expect(page).to have_link(dataset.contact_email)
        expect(page).to have_content(dataset.contact_name)
      end
    end

    scenario 'Is displayed if available on the organisation' do
      organisation = build :organisation, :raw, contact_name: 'Mr. Contact',
                                                contact_email: 'mr.contact@example.com'

      dataset = build :dataset, organisation: organisation
      index_and_visit(dataset)

      expect(page).to have_css('h2', text: 'Contact')
      expect(page).to have_css('h3', text: 'Enquiries')

      within('section.contact .enquiries') do
        expect(page).to have_link(dataset.organisation.contact_email)
        expect(page).to have_content(dataset.organisation.contact_name)
      end
    end
  end

  feature 'Contact FOI' do
    scenario 'Is not displayed if not available' do
      dataset = build :dataset
      index_and_visit(dataset)
      expect(page).to_not have_css('h2', text: 'Contact')
    end

    scenario 'Is displayed if available' do
      dataset = build :dataset, foi_name: 'Mr. FOI',
                                foi_email: 'mr.foi@example.com',
                                foi_web: 'http://foi.com'

      index_and_visit(dataset)
      expect(page).to have_css('h2', text: 'Contact')
      expect(page).to have_css('h3', text: 'Freedom of Information (FOI) requests')

      within('section.contact .foi') do
        expect(page).to have_content(dataset.foi_name)
        expect(page).to have_content(dataset.foi_email)
        expect(page).to have_link(dataset.foi_web, href: dataset.foi_web)
      end
    end

    scenario 'Is displayed if available on the organisation' do
      organisation = build :organisation, :raw, foi_name: 'Mr. FOI',
                                                foi_email: 'mr.foi@example.com',
                                                foi_web: 'http://foi.com'

      dataset = build :dataset, organisation: organisation
      index_and_visit(dataset)

      expect(page).to have_css('h2', text: 'Contact')
      expect(page).to have_css('h3', text: 'Freedom of Information (FOI) requests')

      within('section.contact .foi') do
        expect(page).to have_content(dataset.organisation.foi_name)
        expect(page).to have_content(dataset.organisation.foi_email)

        expect(page).to have_link(dataset.organisation.foi_web,
                                  href: dataset.organisation.foi_web)
      end
    end
  end

  feature 'Displaying datasets', js: true do
    let(:dataset) { build :dataset, datafiles: build_list(:datafile, 20, :raw) }

    scenario 'Show more and show less' do
      index_and_visit(dataset)

      expect(page).to have_css('js-show-more-datafiles', count: 0)
      expect(page).to have_css('.dgu-datafile', count: 5)
      expect(page).to have_css('.show-toggle', text: 'Show more')

      find('.show-toggle').click

      expect(page).to have_css('.dgu-datafile', count: 20)
      expect(page).to have_css('.show-toggle', text: 'Show less')
    end
  end

  feature 'Datafiles' do
    let(:datafile1) { build :datafile, :raw, start_date: '2000/01/01' }
    let(:datafile2) { build :datafile, :raw, start_date: '2002/01/01' }
    let(:datafile3) { build :datafile, :raw }
    let(:dataset) { build :dataset, datafiles: [datafile1, datafile2, datafile3] }

    scenario 'are grouped by year when they contain timeseries datafiles' do
      index_and_visit(dataset)
      expect(page).to have_css(".dgu-datafiles__year", count: 2)

      correct_order = [
        Time.parse(datafile2['start_date']).year.to_s,
        Time.parse(datafile1['start_date']).year.to_s
      ]

      actual_order = all('button.dgu-datafiles__year').map(&:text)
      expect(actual_order).to eq correct_order
    end

    scenario 'are not grouped when they contain non timeseries datafiles' do
      dataset = build :dataset, :with_datafile
      index_and_visit(dataset)
      expect(page).to have_css(".dgu-datalinks__year", count: 0)
    end
  end

  feature 'not released label' do
    scenario 'released is set to false' do
      dataset = build :dataset, released: false
      index_and_visit(dataset)
      expect(page).to have_content 'Not released'
    end

    scenario 'released is set to true' do
      dataset = build :dataset, released: true
      index_and_visit(dataset)
      expect(page).to have_no_content('Not released')
    end
  end

  feature 'contact instructions' do
    scenario 'publisher contact details exist' do
      dataset = build :dataset, contact_email: 'foo@bar.com'
      index_and_visit(dataset)
      expect(page).to have_content("Contact the publisher for more information.")
    end

    scenario 'publisher contact details do not exist' do
      dataset = build :dataset
      index_and_visit(dataset)
      expect(page).to have_content("Contact the team on data.gov.uk/support if you have any questions.")
    end
  end

  feature 'publisher edit link' do
    scenario 'cannot edit harvested dataset' do
      dataset = build :dataset, legacy_name: 'abc123', harvested: true
      index_and_visit(dataset)
      expect(page).to_not have_link('Sign in', href: '/dataset/edit/abc123')
    end

    scenario 'edit released dataset link with datafile' do
      dataset = build :dataset, :with_datafile, legacy_name: 'abc123'
      index_and_visit(dataset)
      expect(page).to have_link('Sign in', href: '/dataset/edit/abc123')
    end

    scenario 'edit released dataset link with doc' do
      dataset = build :dataset, docs: [build(:doc, :raw)], legacy_name: 'abc123'
      index_and_visit(dataset)
      expect(page).to have_link('Sign in', href: '/dataset/edit/abc123')
    end

    scenario 'edit not released dataset link' do
      dataset = build :dataset, legacy_name: 'abc123'
      index_and_visit(dataset)
      expect(page).to have_link('Sign in', href: '/dataset/edit/abc123')
    end
  end
end
