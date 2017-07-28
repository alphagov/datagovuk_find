require 'rails_helper'

RSpec.describe DatasetsHelper, type: :helper, elasticsearch: true do
  config = {
      host: ENV.fetch("ES_HOST", "http://127.0.0.1:9200"),
      transport_options: {
          request: {timeout: 5}
      }
  }

  let(:client) { Elasticsearch::Client.new(config)}

  describe "expected_update" do
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

    after(:each) do
      client.indices.delete index: "datasets-#{Rails.env}"
    end

  end
end
