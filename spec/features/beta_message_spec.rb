require "rails_helper"

RSpec.feature "Combined data.gov.uk and beta banner", type: :feature do
  scenario "Is displayed on all pages for a first time visitor", js: true do
    dataset = build :dataset
    index(dataset)

    paths = [
      dataset_path(dataset.uuid, dataset.name),
      root_path,
      search_path(q: "query")
    ]

    paths.each do |path|
      visit path

      within '.dgu-beta__message' do
        expect(page).to have_content('We’ve been improving data.gov.uk')
      end
      expect(page).to have_selector('#dgu-beta__banner', visible: true)
    end
  end

  scenario "Dismissing banner on search page works and retains query", js: true do
    dataset = build :dataset, title: 'Zebra data'
    index(dataset)
    visit search_path(q: 'zebra')

    expect(page).to have_field('Search', with: 'zebra')
    expect(page).to_not have_selector('.dgu-beta__banner--hidden')

    within '.dgu-beta__message' do
      click_link "Don't show this message again"
    end

    expect(page).to have_field('Search', with: 'zebra')
    expect(page).to have_selector('.dgu-beta__banner--hidden', visible: false)
    expect(page).to have_selector('#dgu-beta__banner', visible: false)
  end
end

RSpec.feature "Beta banner", type: :feature do
  it "is displayed on all pages after the combined banner is dismissed", js: true do
    dataset = build :dataset
    index(dataset)
    visit root_path

    within '.dgu-beta__message' do
      click_link "Don't show this message again"
    end

    paths = [
      dataset_path(dataset.uuid, dataset.name),
      root_path,
      search_path(q: "query"),
      about_path,
      support_path
    ]

    paths.each do |path|
      visit path

      expect(page).to have_selector('#dgu-phase-banner', visible: true)
      within '#dgu-phase-banner' do
        expect(page).to have_content('This is a new service – your feedback will help us to improve it')
      end

      expect(page).to_not have_selector('.phase-banner--hidden')
    end
  end
end
