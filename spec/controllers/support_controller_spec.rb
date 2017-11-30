require 'rails_helper'

describe SupportController, type: :controller do
  it 'sends a create ticket request to zendesk' do
    stub_request(:post, 'https://test.com/tickets').to_return(status: 200)

    params = { name: 'test-user', email: 'test-user@mail.com', content: 'help!', support: 'feedback' }
    ticket = ZendeskTicket.new(params).send(:build_ticket)


    post :ticket, params: params
    expect(WebMock)
      .to have_requested(:post, 'https://test.com/tickets')
      .with(body: {"ticket": ticket})
  end
end
