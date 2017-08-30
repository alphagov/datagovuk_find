require 'rails_helper'

describe 'Authentication' do
  context 'Consent page' do
    fit 'redirects the user to the consent page if they have not consented' do
      visit '/'
      expect(page).to have_content('Consent')
      click_link 'I consent'
      expect(current_path).to eq '/'
    end
  end
end
