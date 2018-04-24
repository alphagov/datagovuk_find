require 'rails_helper'

describe TicketsController, type: :controller do
  ZENDESK_END_POINT = "https://test_zendesk_url.com/api/v2/tickets".freeze

  describe "#create" do
    context "when the user input is valid" do
      valid_params = { zendesk_ticket: { name: 'test-user', email: 'test-user@mail.com', content: 'help!', support: 'feedback' } }
      subject { post :create, params: valid_params }

      it 'user is redirected to confirmation page and request is sent to zendesk' do
        stub_request(:post, ZENDESK_END_POINT).to_return(status: 200)
        ticket = ZendeskTicket.new(valid_params[:zendesk_ticket]).send(:build_ticket)

        expect(subject).to redirect_to tickets_confirmation_path

        expect(WebMock)
        .to have_requested(:post, ZENDESK_END_POINT)
        .with(body: { "ticket": ticket })
      end
    end

    context "when the user input is invalid" do
      invalid_params = { zendesk_ticket: { name: 'test-user', email: 'test-user', content: 'help!', support: 'feedback' } }
      subject { post :create, params: invalid_params }

      it 'user is not redirected to confirmation page and no request is sent to zendesk' do
        expect(subject).not_to redirect_to tickets_confirmation_path
        expect(response.request.path_info).to eq tickets_path

        ticket = ZendeskTicket.new(invalid_params[:zendesk_ticket]).send(:build_ticket)

        expect(WebMock)
        .to_not have_requested(:post, ZENDESK_END_POINT)
        .with(body: { "ticket": ticket })
      end
    end
  end
end
