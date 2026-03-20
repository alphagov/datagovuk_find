require "rails_helper"

RSpec.feature "basic auth", type: :feature do
  before do
    stub_const("ENV", ENV.to_hash.merge("BASIC_AUTH_USERNAME" => "test-username"))
    stub_const("ENV", ENV.to_hash.merge("BASIC_AUTH_PASSWORD" => "test-password"))
    stub_const("ENV", ENV.to_hash.merge("BASIC_AUTH_BYPASS" => "some-header"))
  end

  scenario "I visit the homepage without setting authentication" do
    visit "/"
    expect(page).to have_http_status(:unauthorized)
  end

  scenario "I visit the homepage with good authentication" do
    page.driver.browser.authorize("test-username", "test-password")
    visit "/"
    expect(page).to have_http_status(:ok)
  end

  scenario "I visit the homepage with basic auth bypass header" do
    page.driver.header "some-header", "some-value"
    visit "/"
    expect(page).to have_http_status(:ok)
  end

  scenario "I visit the healthcheck page without setting authentication" do
    visit "/healthz"
    expect(page).to have_http_status(:ok)
  end
end
