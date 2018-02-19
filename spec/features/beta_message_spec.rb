require "rails_helper"

feature "Combined dgu and beta banner" do
  scenario "Is displayed on all pages for a first time visitor" do

    dataset = DatasetBuilder.new.build
    index([dataset])
    paths = [
      dataset_path(dataset[:short_id], dataset[:name]),
      root_path,
      search_path(q: "query")
    ]

    paths.each do |path|
      visit path
      expect(page).to have_css(".dgu-beta__message")
      expect(page).to have_content("We’ve been improving data.gov.uk")
    end
  end

  scenario "Dismissing banner on search page works and retains query" do

    dataset = DatasetBuilder.new
              .with_title("Zebra data")
              .build
    index([dataset])
    visit search_path(q: "zebra")

    expect(page).to have_content("zebra")
    click_link "Don't show this message again"
    expect(page).to have_content("zebra")
    expect(page).to_not have_css(".dgu-beta__message")
  end

  scenario "Dismissing banner on dataset page works" do

    dataset = DatasetBuilder.new
              .with_title("Zebra data")
              .build
    index_and_visit(dataset)

    expect(page).to have_content("Zebra")
    click_link "Don't show this message again"
    expect(page).to have_content("Zebra")
    expect(page).to_not have_css(".dgu-beta__message")
  end
end

feature "Beta banner" do
  it "is displayed on all pages after the combined banner is dismissed" do
    dataset = DatasetBuilder.new.build
    index([dataset])

    visit root_path

    within ".dgu-beta__banner" do
      click_link("Don't show this message again")
    end

    paths = [
      dataset_path(dataset[:short_id], dataset[:name]),
      root_path,
      search_path(q: "query"),
      about_path,
      support_path
    ]

    paths.each do |path|
      visit path
      expect(page).to have_css(".phase-banner")
      expect(page).to have_content("This is a new service")
      expect(page).not_to have_css(".dgu-beta__banner")
    end


  end
end
