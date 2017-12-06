require 'rails_helper'

describe ZendeskTicket do

  it '#send_ticket' do

    ticket_details = {
      "requester": { "name": 'test-user', "email": 'test-user@mail.com' },
      "subject": "[DGU] Find Data Beta support request",
      "comment": {"body": 'help!'}
    }

    params = { name: 'test-user',
               email: 'test-user@mail.com',
               content: 'help!',
               support: 'feedback'
              }
    expect(Rails.logger).to receive(:info).with("Zendesk ticket created: #{ticket_details}")

    ZendeskTicket.new(params).send_ticket

  end
end
