# coding: utf-8
require 'rails_helper'


feature 'Search page', elasticsearch: true do
  scenario 'Displays a not found message when a search returns 0 results' do
    query = 'interesting dataset'

    search_for(query)

    expect(page).to have_css('h1', text: 'Search results')
    expect(page).to have_content("0 results found for '#{query}'")
  end

  scenario 'Displays search results' do
    dataset_title = 'A very interesting dataset'
    query = 'interesting dataset'

    dataset = DatasetBuilder.new
                .with_title(dataset_title)
                .build

    index(dataset)
    search_for(query)

    expect(page).to have_css('h1', text: 'Search results')
    expect(page).to have_css('a', text: dataset_title)
  end

  scenario 'Search results are correctly sorted' do
    old_dataset = DatasetBuilder.new
                    .with_title('Old Interesting Dataset')
                    .with_name('old-dataset')
                    .last_updated_at('2014-07-24T14:47:25.975Z')
                    .build

    new_dataset = DatasetBuilder.new
                    .with_title('Recent Interesting Dataset')
                    .with_name('new-dataset')
                    .last_updated_at('2017-07-24T14:47:25.975Z')
                    .build

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

    first_dataset = DatasetBuilder.new
                      .with_title('Data About Tonka Trucks')
                      .with_publisher('Tonka Trucks')
                      .build

    second_dataset = DatasetBuilder.new
                      .with_title('Data About Toby')
                      .with_publisher('Toby Corp')
                      .build

    index(first_dataset, second_dataset)

    visit('/search')

    assert_data_set_length_is(2)

    execute_script "window.location = '#publisher'"

    find_field('publisher').send_keys('Tob', :down, :enter)
    click_button 'Apply filters'

    search_results_headings = all('h2 a').map(&:text)
    expect(search_results_headings.length).to be(1)
    expect(search_results_headings).to contain_exactly 'Data About Toby'
    expect(page).not_to have_content('Data About Tonka Trucks')
  end

  scenario 'filter by OGL licence' do
    first_dataset = DatasetBuilder.new
                      .with_title('First Dataset Title')
                      .with_licence('uk-ogl')
                      .build

    second_dataset = DatasetBuilder.new
                      .with_title('Second Dataset Title')
                      .with_licence('foo')
                      .build

    index(first_dataset, second_dataset)

    visit('/search')

    assert_data_set_length_is(2)

    check('Open Government Licence (OGL) only')

    within('.dgu-filters__apply-button') do
      find('.button').click
    end

    results = all('h2 a')
    expect(results.length).to be(1)
    expect(results[0]).to have_content 'First Dataset Title'
  end

  scenario 'filter by topic', js: true do
    first_dataset = DatasetBuilder.new
                      .with_title('First Dataset Title')
                      .with_topic({id: 1, name: "government", title: "Government"})
                      .build

    second_dataset = DatasetBuilder.new
                      .with_title('Second Dataset Title')
                      .with_topic({id: 2, name: "business-and-economy", title: "Business and economy"})
                      .build

    index(first_dataset, second_dataset)

    visit('/search')

    assert_data_set_length_is(2)

    execute_script "window.location = '#topic'"

    find_field('topic').send_keys('Gov', :down, :enter)
    click_button 'Apply filters'

    search_results_headings = all('h2 a').map(&:text)
    expect(search_results_headings.length).to be(1)
    expect(search_results_headings).to contain_exactly 'First Dataset Title'
  end

  scenario 'filter by datafile format', js: true do
    first_dataset = DatasetBuilder.new
                      .with_title('First Dataset Title')
                      .with_datafiles([{'format' => 'foo'}])
                      .build

    second_dataset = DatasetBuilder.new
                      .with_title('Second Dataset Title')
                      .with_datafiles([{'format' => 'bar'}])
                      .build

    index(first_dataset, second_dataset)

    visit('/search')

    assert_data_set_length_is(2)

    execute_script "window.location = '#format'"
    find_field('format').send_keys('FO', :down, :enter)
    click_button 'Apply filters'

    search_results_headings = all('h2 a').map(&:text)
    expect(search_results_headings.length).to be(1)
    expect(search_results_headings).to contain_exactly 'First Dataset Title'
    expect(page).to have_content 'Datasets filtered by FOO'
  end

  scenario 'Searching for a phrase' do
    index(DatasetBuilder.new.with_title('A very interesting dataset').build,
          DatasetBuilder.new.with_title('A fairly interesting dataset').build)

    search_for('"Very interesting"')

    assert_search_results_headings('A very interesting dataset')
  end

  scenario 'Searching for a malformed phrase' do
    index(DatasetBuilder.new.with_title('A very interesting dataset').build,
          DatasetBuilder.new.with_title('A fairly interesting dataset').build)

    search_for('"Very interesting')

    assert_search_results_headings(
      'A very interesting dataset',
      'A fairly interesting dataset'
    )
  end

  def assert_data_set_length_is(count)
    datasets = all('h2 a')
    expect(datasets.length).to be(count)
  end

  def assert_search_results_headings(*headings)
    expect(all('h2 a').map(&:text)).to contain_exactly(*headings)
  end
end
