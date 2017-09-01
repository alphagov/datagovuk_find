require 'rails_helper'


feature 'Previews' do
  xscenario 'when a preview exists, show it' do
    expected_preview = JSON.dump({ "what is this?": "it's an example preview" })

    stub_request(:any, "https://publish-data-beta.herokuapp.com").to_return(:status => 200, :body => expected_preview, :headers => {})

    expect(RestClient).to receive(:get).with(anything).and_return(expected_preview)

    visit '/file/1/preview'

    expect(page).to have_content(expected_preview)
  end

  xscenario 'when a preview does not exist, show an error' do
    visit '/file/-213435265736/preview'

    expect(page).to have_http_status(404)
  end
end
