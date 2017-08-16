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
end
