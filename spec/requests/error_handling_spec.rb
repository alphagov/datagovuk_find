require "rails_helper"
require "securerandom"

RSpec.describe "Error handling", type: :request do
  it "handles a Dataset that can't be found by legacy name" do
    mock_solr_http_error(status: 404)
    get "/dataset/missing"

    expect(response).to have_http_status(:not_found)
  end

  it "handles a Dataset that can't be found by UUID" do
    mock_solr_http_error(status: 404)
    get "/dataset/#{SecureRandom.uuid}"

    expect(response).to have_http_status(:not_found)
  end

  it "handles a Datafile that can't be found by UUID" do
    mock_solr_http_error(status: 404)
    dataset = double(name: "a-very-interesting-dataset", uuid: "123")

    get "/dataset/#{dataset.uuid}/#{dataset.name}/datafile/#{SecureRandom.uuid}/preview"
    expect(response).to have_http_status(:not_found)
  end

  it "handles a legacy Datafile that can't be found by UUID" do
    mock_solr_http_error(status: 404)
    dataset = double(name: "a-very-interesting-dataset", uuid: "123")

    get "/dataset/#{dataset.name}/resource/#{SecureRandom.uuid}"
    expect(response).to have_http_status(:not_found)
  end
end
