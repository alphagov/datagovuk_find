require 'rails_helper'

RSpec.feature 'Support tickets', type: :feature do
  before do
    visit support_path
  end

  feature 'Reporting a problem' do
    let(:ticket) { build :ticket, support: 'feedback' }

    scenario 'Send a support ticket to Zendesk' do
      choose 'I want to report a problem'
      click_on 'Continue'
      expect(page).to have_content 'Report a problem'

      fill_in 'example-content', with: ticket.content
      fill_in 'example-name', with: ticket.name
      fill_in 'example-email', with: ticket.email

      expect(Zendesk.client)
        .to receive_message_chain('tickets.create!')
        .with(ticket.to_json)

      click_on 'Submit'
      expect(page).to have_content 'Thanks for contacting data.gov.uk'
    end
  end

  feature 'Asking for data' do
    let(:ticket) { build :ticket, support: 'data' }

    scenario 'Send a support ticket to Zendesk' do
      choose 'I have a data request'
      click_on 'Continue'
      expect(page).to have_content 'Send a data request'

      fill_in 'example-content', with: ticket.content
      fill_in 'example-name', with: ticket.name
      fill_in 'example-email', with: ticket.email

      expect(Zendesk.client)
        .to receive_message_chain('tickets.create!')
        .with(ticket.to_json)

      click_on 'Submit'
      expect(page).to have_content 'Thanks for contacting data.gov.uk'
    end
  end

  feature 'Becoming a publisher' do
    let(:ticket) { build :ticket, support: 'publish' }

    scenario 'Send a support ticket to Zendesk' do
      choose 'I want to publish for an organisation'
      click_on 'Continue'
      expect(page).to have_content 'Publish for an organisation'

      fill_in 'example-content', with: ticket.content
      fill_in 'example-name', with: ticket.name
      fill_in 'example-email', with: ticket.email

      expect(Zendesk.client)
        .to receive_message_chain('tickets.create!')
        .with(ticket.to_json)

      click_on 'Submit'
      expect(page).to have_content 'Thanks for contacting data.gov.uk'
    end
  end

  feature 'Recover from invalid data' do
    let(:ticket) { build :ticket, email: 'foo' }

    scenario 'Show the errors in the ticket form' do
      choose 'I have a data request'
      click_on 'Continue'
      fill_in 'example-email', with: ticket.email

      click_on 'Submit'
      expect(page).to have_content 'Enter a valid email address'
      expect(page).to have_content 'Enter a name'
      expect(page).to have_content 'Enter a message'
    end
  end
end
