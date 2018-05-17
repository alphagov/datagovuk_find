require 'rails_helper'

RSpec.describe 'legacy', type: :request do
  describe 'dataset creation' do
    it 'shows a page informing the user the newly created dataset will be available soon' do
      get '/dataset/foo-bar', params: {}, headers: { 'HTTP_REFERER' => "http://foobar.com/dataset/new/" }

      expect(response.body).to include("Changes to your datasets")
    end
  end
end
