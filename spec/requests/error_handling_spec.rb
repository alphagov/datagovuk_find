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
    dataset_name = 'my-dataset'
    dataset_uuid = SecureRandom.uuid
    datafile_uuid = SecureRandom.uuid

    dataset = DatasetBuilder
                .new
                .with_name(dataset_name)
                .with_uuid(dataset_uuid)
                .build

    index(dataset)

    get "/dataset/#{dataset_uuid}/#{dataset_name}/datafile/#{datafile_uuid}/preview"

    expect(response).to have_http_status(:not_found)
  end
end
