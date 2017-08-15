require 'rails_helper'

feature 'Previews', elasticsearch: true do
  scenario 'when a preview exists, show it' do
    expected_preview = JSON.dump({ "what is this?": "it's an example preview" })
    expect(RestClient).to receive(:get).and_return(expected_preview)

    visit '/file/1/preview'

    expect(page).to have_content(expected_preview)
  end

  scenario 'when a preview does not exist, show an error' do
    visit '/file/-213435265736/preview'

    expect(page).to have_http_status(404)
  end
end
