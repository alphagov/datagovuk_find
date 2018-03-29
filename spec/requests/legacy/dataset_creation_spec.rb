require 'rails_helper'

describe 'legacy', type: :request do
  describe 'dataset creation' do
    it 'shows a page informing the user the newly created dataset will be available soon' do
      post '/dataset/foo-bar'

      expect(response.body).to include("Available Soon")
    end
  end
end
