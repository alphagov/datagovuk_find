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

  describe "expected_update metadata" do
    # updated_at: "2017-07-24T14:47:25.975Z"

    it "annual" do
      dataset = create_dataset("Lovely data", "annual")
      index_and_visit(dataset)
      expect(page).to have_content("Expected update: 24 July 2018")
    end

    it "quarterly" do
      dataset = create_dataset("Lovely data", "quarterly")
      index_and_visit(dataset)
      expect(page).to have_content("Expected update: 24 November 2017")
    end

    it "monthly" do
      dataset = create_dataset("Lovely data", "monthly")
      index_and_visit(dataset)
      expect(page).to have_content("Expected update: 24 August 2017")
    end

    it "daily" do
      dataset = create_dataset("Lovely data", "daily")
      index_and_visit(dataset)
      expect(page).to have_content("Expected update: 25 July 2017")
    end

    it "never, one off" do
      ["never", "one off"].each do |freq|
        dataset = create_dataset("Lovely data", freq)
        index_and_visit(dataset)
        expect(page).to have_content("No future updates")
      end
    end

    it "discontinued" do
      dataset = create_dataset("Lovely data", "discontinued")
      index_and_visit(dataset)
      expect(page).to have_content("Dataset no longer updated")
    end
  end

  describe "location metadata" do
    it 'displays a location if there is one' do
      dataset = create_dataset("Lovely data")
      index_and_visit(dataset)
      expect(page).to have_content("Geographical area: London Southwark")
    end
  end

  after(:each) do
    client.indices.delete index: "datasets-#{Rails.env}"
  end

end
