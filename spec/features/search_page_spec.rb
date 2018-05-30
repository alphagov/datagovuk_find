# coding: utf-8

require 'rails_helper'

RSpec.feature 'Search page', type: :feature, elasticsearch: true do
  scenario 'Displays a not found message when a search returns 0 results' do
    search_for('interesting dataset')
    expect(page).to have_css('h1', text: 'Search results')
    expect(page).to have_content("0 results found")
  end

  scenario 'Displays search results' do
    dataset = build :dataset, title: 'A very interesting dataset'
    index(dataset)
    search_for('interesting dataset')

    expect(page).to have_css('h1', text: 'Search results')
    expect(page).to have_css('a', text: dataset.title)
  end

  scenario 'Search results indicate dataset availability' do
    index(build(:dataset, released: true))
    search_for('')
    expect(page).to have_no_content 'Not released'

    index(build(:dataset, released: false))
    search_for('')
    expect(page).to have_content 'Not released'
  end

  scenario 'Search results are correctly sorted' do
    old_dataset = build :dataset, title: 'Old Interesting Dataset', public_updated_at: 1.hour.ago
    new_dataset = build :dataset, title: 'Recent Interesting Dataset'
    index(old_dataset, new_dataset)

    search_for('Old Interesting Dataset')
    expect(page).to have_css('option[selected]', text: 'Best match')

    elements = all('h2 a')
    expect(elements[0]).to have_content 'Old'
    expect(elements[1]).to have_content 'Recent'

    filtered_search_for('Interesting Dataset', 'Most recent')
    expect(page).to have_css('option[selected]', text: 'Most recent')

    elements = all('h2 a')
    expect(elements[0]).to have_content 'Recent'
    expect(elements[1]).to have_content 'Old'

    filtered_search_for('Old Interesting Dataset', 'Best match')
    expect(page).to have_css('option[selected]', text: 'Best match')

    elements = all('h2 a')
    expect(elements[0]).to have_content 'Old'
    expect(elements[1]).to have_content 'Recent'
  end

  scenario 'Match publisher query against available publishers', js: true do
    dataset1 = build :dataset, title: 'Wanted'
    dataset2 = build :dataset, :unrelated, title: 'Unrelated'

    index(dataset1, dataset2)
    visit('/search')
    assert_data_set_length_is(2)

    execute_script "window.location = '#publisher'"
    find_field('publisher').send_keys('Minist', :down, :enter)
    click_button 'Apply filters'

    search_results_headings = all('h2 a').map(&:text)
    expect(search_results_headings.length).to be(1)
    expect(search_results_headings).to contain_exactly dataset1.title
    expect(page).not_to have_content dataset2.title
  end

  scenario 'filter by OGL licence' do
    dataset1 = build :dataset, :with_ogl_licence
    dataset2 = build :dataset, :unrelated

    index(dataset1, dataset2)
    visit('/search')
    assert_data_set_length_is(2)

    check('Open Government Licence (OGL) only')

    within('.dgu-filters__apply-button') do
      find('.button').click
    end

    results = all('h2 a')
    expect(results.length).to be(1)
    expect(results[0]).to have_content dataset1.title
  end

  scenario 'filter by topic', js: true do
    dataset1 = build :dataset, :with_topic
    dataset2 = build :dataset, :unrelated

    index(dataset1, dataset2)
    visit('/search')
    assert_data_set_length_is(2)

    execute_script "window.location = '#topic'"
    find_field('topic').send_keys('Gov', :down, :enter)
    click_button 'Apply filters'

    search_results_headings = all('h2 a').map(&:text)
    expect(search_results_headings.length).to be(1)
    expect(search_results_headings).to contain_exactly dataset1.title
  end

  scenario 'filter by datafile format', js: true do
    dataset1 = build :dataset, :with_datafile
    dataset2 = build :dataset, :unrelated

    index(dataset1, dataset2)
    visit('/search')
    assert_data_set_length_is(2)

    execute_script "window.location = '#format'"
    find_field('format').send_keys('CSV', :down, :enter)
    click_button 'Apply filters'

    search_results_headings = all('h2 a').map(&:text)
    expect(search_results_headings.length).to be(1)
    expect(search_results_headings).to contain_exactly dataset1.title
  end

  scenario 'Searching for a phrase' do
    index(build(:dataset, title: 'A very interesting dataset'),
          build(:dataset, title: 'A fairly interesting dataset'))

    search_for('"Very interesting"')
    assert_search_results_headings('A very interesting dataset')
  end

  scenario 'Searching for a malformed phrase' do
    index(build(:dataset, title: 'A very interesting dataset'),
          build(:dataset, title: 'A fairly interesting dataset'))

    search_for('"Very interesting')

    assert_search_results_headings('A very interesting dataset',
                                   'A fairly interesting dataset')
  end

  scenario 'Search with a possessive query' do
    index(build(:dataset, title: 'Government'))
    search_for("Government's")
    assert_search_results_headings('Government')
  end

  scenario 'Search with lowercase query' do
    dataset = build :dataset, title: 'DEFRA'
    index(dataset)
    search_for(dataset.title.downcase)
    assert_search_results_headings(dataset.title)
  end

  scenario 'Prominence of datasets based on organisation category' do
    dataset1 = build :dataset, organisation: build(:organisation, :raw)
    dataset2 = build :dataset, organisation: build(:organisation, :raw, :non_ministerial_department)
    dataset3 = build :dataset, organisation: build(:organisation, :raw, :non_departmental_public_body)
    dataset4 = build :dataset, organisation: build(:organisation, :raw, :local_council)
    index(dataset1, dataset2, dataset3, dataset4)

    search_for('data')
    publishers = all('dd.published_by').map(&:text)

    publishers[0..2].each do |publisher|
      expect(publisher).to eq('Ministry of Defence')
                       .or eq('English Heritage')
                       .or eq('Forestry Commission')
    end

    expect(publishers[3]).to eq('Plymouth City Council')
  end

  scenario 'search results title', js: true do
    index(build(:dataset, :with_topic))
    search_for("apple")
    expect(page).to have_title('Results for "apple"')

    search_for("")
    expect(page).to have_title('Search Results')

    execute_script "window.location = '#topic'"
    find_field('topic').send_keys('Gov', :down, :enter)
    click_button 'Apply filters'

    expect(page).to have_title('Results for "Government"')

    within '#content' do
      fill_in 'q', with: 'bear'
      find('.dgu-search-box__button').click
    end

    expect(page).to have_title('Results for "bear"')
  end

  def assert_data_set_length_is(count)
    datasets = all('h2 a')
    expect(datasets.length).to be(count)
  end

  def assert_search_results_headings(*headings)
    expect(all('h2 a').map(&:text)).to contain_exactly(*headings)
  end

  scenario 'search filters are scoped to search query results' do
    dataset1 = build :dataset, :with_topic, :with_datafile
    dataset2 = build :dataset, :unrelated

    index(dataset1, dataset2)
    search_for(dataset1.title)

    expect(page).to have_select('Publisher', options: ['', dataset1.organisation.title])
    expect(page).to have_select('Topic', options: ['', dataset1.topic['title']])
    expect(page).to have_select('Format', options: ['', dataset1.datafiles.first.format])
  end
end
