require 'rails_helper'

describe SupportController, type: :controller do

  describe "#ticket" do

    context "when the user input is valid" do
      valid_params = { name: 'test-user', email: 'test-user@mail.com', content: 'help!', support: 'feedback' }
      subject { post :ticket, params: valid_params }

      it 'redirects to confirmation page' do
        expect(subject).to redirect_to support_confirmation_path
      end
    end
  end
end
