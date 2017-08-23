require 'rails_helper'
require 'json'

feature 'Status page' do
  scenario 'status information is shown' do
    visit '/status'

    expect(page.status_code).to eq(200)
    page_json = JSON.parse(page.body)

    expect(page_json.keys).to eq(['status', 'version', 'date'])
    expect(page_json['status']).to eq('ok')
    expect(page_json['version']).to_not be_empty
    expect(page_json['date']).to_not be_empty
  end
end
