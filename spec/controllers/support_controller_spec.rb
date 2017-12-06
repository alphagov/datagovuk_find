require 'rails_helper'

describe SupportController, type: :controller do

  describe "#ticket" do

    context "when the user input is valid" do
      valid_params = { zendesk_ticket: { name: 'test-user', email: 'test-user@mail.com', content: 'help!', support: 'feedback' }}
      subject { post :ticket, params: valid_params }

      it 'redirects to confirmation page' do
        expect(subject).to redirect_to support_confirmation_path
      end
    end

    context "when the user input is invalid" do
      invalid_params = { zendesk_ticket: { name: 'test-user', email: 'test-user', content: 'help!', support: 'feedback' }}
      subject { post :ticket, params: invalid_params }

      it 'does not redirect to confirmation page' do
        expect(subject).not_to redirect_to support_confirmation_path
        expect(response.request.path_info).to eq support_ticket_path
      end
    end

  end
end
