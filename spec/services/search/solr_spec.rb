require "rails_helper"

RSpec.describe Search::Solr do
  before do
    ENV["SOLR_URL"] = "http://localhost:8983/solr"
  end

  describe "#client" do
    let(:client) { described_class.client }

    it "is an instance of the RSolr client" do
      expect(client).to be_an_instance_of(RSolr::Client)
    end

    it "connects to Solr with a valid URL" do
      expect(client.options[:url]).to eq(ENV["SOLR_URL"])
    end

    it "only sets up the connection once" do
      client1 = described_class.client
      expect(client1).to eq(client)
    end
  end

  describe "#search" do
    let(:response) { File.read(Rails.root.join("spec/fixtures/solr_response.json").to_s) }
    let(:results) { described_class.search("q" => "") }

    before do
      allow_any_instance_of(RSolr::Client).to receive(:get).and_return(JSON.parse(response))
    end

    it "returns a JSON response" do
      expect(results).to be_a(Hash)
    end

    it "includes a count of the results" do
      expect(results["response"]["numFound"]).to eq(2)
    end

    it "includes the datasets" do
      datasets = results["response"]["docs"]
      expect(datasets.length).to eq(2)
    end

    context "datasets" do
      let(:dataset) { results["response"]["docs"].first }

      it "includes the id" do
        expect(dataset["id"]).to eq("420932c7-e6f8-43ea-adc5-3141f757b5cb")
      end

      it "includes the name" do
        expect(dataset["name"]).to eq("a-very-interesting-dataset")
      end

      it "includes the title" do
        expect(dataset["title"]).to eq("A very interesting dataset")
      end

      it "includes the notes" do
        expect(dataset["notes"]).to eq("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec euismod mauris in augue laoreet congue. Phasellus bibendum leo vel magna lacinia eleifend. Nam vitae lectus quis nulla varius faucibus id quis nibh. Nullam auctor ipsum non nunc efficitur bibendum Sed vitae ex nisi. Suspendisse posuere purus ac dui posuere, in interdum risus ornare. \n\nThe following files can be found on the website here:\n\nhttps://www.gov.uk/")
      end

      it "includes the last updated date" do
        expect(dataset["metadata_modified"]).to eq("2017-06-30T09:08:37.040Z")
      end

      it "includes the organization slug" do
        expect(dataset["organization"]).to eq("department-for-communities-and-local-government")
      end

      it "includes the organization name" do
        data_dict = JSON.parse(dataset["validated_data_dict"])
        expect(data_dict["organization"]["title"]).to eq("Ministry of Housing, Communities and Local Government")
      end
    end
  end

  describe "get_by_uuid" do
    let(:response) { JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_dataset.json").to_s)) }
    let(:results) { described_class.get_by_uuid(uuid: "420932c7-e6f8-43ea-adc5-3141f757b5cb") }

    before do
      allow_any_instance_of(RSolr::Client).to receive(:get).and_return(response)
    end

    it "returns one result" do
      expect(results["response"]["numFound"]).to eq(1)
    end

    it "returns one dataset" do
      expect(results["response"]["docs"].count).to eq(1)
    end

    context "datasets" do
      let(:dataset) { results["response"]["docs"].first }

      it "includes the id" do
        expect(dataset["id"]).to eq("420932c7-e6f8-43ea-adc5-3141f757b5cb")
      end

      it "includes the name" do
        expect(dataset["name"]).to eq("a-very-interesting-dataset")
      end

      it "includes the title" do
        expect(dataset["title"]).to eq("A very interesting dataset")
      end

      it "includes the notes" do
        expect(dataset["notes"]).to eq("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec euismod mauris in augue laoreet congue. Phasellus bibendum leo vel magna lacinia eleifend. Nam vitae lectus quis nulla varius faucibus id quis nibh. Nullam auctor ipsum non nunc efficitur bibendum Sed vitae ex nisi. Suspendisse posuere purus ac dui posuere, in interdum risus ornare. \n\nThe following files can be found on the website here:\n\nhttps://www.gov.uk/")
      end

      it "includes the last updated date" do
        expect(dataset["metadata_modified"]).to eq("2017-06-30T09:08:37.040Z")
      end

      it "includes the organization slug" do
        expect(dataset["organization"]).to eq("department-for-communities-and-local-government")
      end

      it "includes the organization name" do
        data_dict = JSON.parse(dataset["validated_data_dict"])
        expect(data_dict["organization"]["title"]).to eq("Ministry of Housing, Communities and Local Government")
      end
    end
  end
end