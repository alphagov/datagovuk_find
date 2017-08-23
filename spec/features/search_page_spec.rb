# coding: utf-8
require 'rails_helper'


feature 'Search page', elasticsearch: true do
  scenario 'Displays a not found message when a search returns 0 results' do
    query = 'interesting dataset'

    search_for(query)

    expect(page).to have_css('h1', text: 'Search results')
    expect(page).to have_content("0 results found for ‘#{query}’")
  end

  scenario 'Displays search results' do
    dataset_title = 'A very interesting dataset'
    query = 'interesting dataset'

    dataset = DatasetBuilder.new
                .with_title(dataset_title)
                .build

    index([dataset])
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

    index([old_dataset, new_dataset])

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

end
