require 'rails_helper'

describe "Datasets", elasticsearch: true do
  config = {
      host: ENV.fetch("ES_HOST", "http://127.0.0.1:9200"),
      transport_options: {
          request: {timeout: 5}
      }
  }

  let(:client) { Elasticsearch::Client.new(config)}

  it "displays a dataset" do
    name = "Fancy pants dataset"
    dataset = create_dataset(name)
    index(dataset)

    visit "/dataset/1"

    expect(page).to have_content("Published by")
    expect(page).to have_content(name)
  end

  after(:each) do
    client.indices.delete index: "datasets-#{Rails.env}"
  end


end
