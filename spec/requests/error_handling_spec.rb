require 'rails_helper'
require 'securerandom'

RSpec.describe 'Error handling', type: :request do
  it "handles a Dataset that can't be found by legacy name" do
    get '/dataset/missing'

    expect(response).to have_http_status(:not_found)
  end

  it "handles a Dataset that can't be found by UUID" do
    get "/dataset/#{SecureRandom.uuid}"

    expect(response).to have_http_status(:not_found)
  end

  it "handles a Datafile that can't be found by UUID" do
    dataset = build :dataset
    index(dataset)

    get "/dataset/#{dataset.uuid}/#{dataset.name}/datafile/#{SecureRandom.uuid}/preview"
    expect(response).to have_http_status(:not_found)
  end
end
