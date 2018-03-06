require "rails_helper"

feature "Combined data.gov.uk and beta banner" do
  scenario "Is displayed on all pages for a first time visitor" do
    dataset = DatasetBuilder.new.build

    index(dataset)

    paths = [
      dataset_path(dataset[:uuid], dataset[:name]),
      root_path,
      search_path(q: "query")
    ]

    paths.each do |path|
      visit path

      within '.dgu-beta__message' do
        expect(page).to have_content('We’ve been improving data.gov.uk')
      end
    end
  end

  scenario "Dismissing banner on search page works and retains query" do
    dataset = DatasetBuilder.new
                .with_title("Zebra data")
                .build

    index(dataset)

    visit search_path(q: 'zebra')

    expect(page).to have_field('Search', with: 'zebra')

    within '.dgu-beta__message' do
      click_link "Don't show this message again"
    end

    expect(page).to have_field('Search', with: 'zebra')
    expect(page).to_not have_selector('.dgu-beta__message')
  end

  scenario "Dismissing banner on dataset page works" do
    dataset = DatasetBuilder.new
                .with_title("Zebra data")
                .build

    index_and_visit(dataset)

    expect(page).to have_selector('h1', text: 'Zebra')

    within '.dgu-beta__message' do
      click_link "Don't show this message again"
    end

    expect(page).to have_selector('h1', text: 'Zebra')
    expect(page).to_not have_selector('.dgu-beta__message')
  end
end

feature "Beta banner" do
  it "is displayed on all pages after the combined banner is dismissed" do
    dataset = DatasetBuilder.new.build

    index(dataset)

    visit root_path

    within '.dgu-beta__message' do
      click_link "Don't show this message again"
    end

    paths = [
      dataset_path(dataset[:uuid], dataset[:name]),
      root_path,
      search_path(q: "query"),
      about_path,
      support_path
    ]

    paths.each do |path|
      visit path

      within '.phase-banner' do
        expect(page).to have_content('This is a new service – your feedback will help us to improve it')
      end

      expect(page).to_not have_selector('.dgu-beta__message')
    end
  end
end
