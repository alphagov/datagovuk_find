require 'rails_helper'

feature 'Beta message' do
  scenario "Is displayed on all pages for a first time visitor" do

    dataset = DatasetBuilder.new.build
    index([dataset])
    paths = [
      dataset_path(dataset[:short_id], dataset[:name]),
      root_path,
      search_path(q: 'query')
    ]

    paths.each do |path|
      visit path
      expect(page).to have_css('.dgu-beta-message')
    end

  end

  scenario "Dismissing message on search page works and retains query" do
    dataset = DatasetBuilder.new
              .with_title('Zebra data')
              .build
    index([dataset])
    visit search_path(q: 'zebra')

    expect(page).to have_content('zebra')
    click_link "Don't show this message again"
    expect(page).to have_content('zebra')
    expect(page).to_not have_css('.dgu-beta-message')
  end

  scenario "Dismissing message on dataset page works" do
    dataset = DatasetBuilder.new
              .with_title('Zebra data')
              .build
    index_and_visit(dataset)

    expect(page).to have_content('Zebra')
    click_link "Don't show this message again"
    expect(page).to have_content('Zebra')
    expect(page).to_not have_css('.dgu-beta-message')
  end

end
