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
      expect(client.options[:url]).to be == ENV["SOLR_URL"]
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

    context "datafiles" do
      let(:dataset) { results["response"]["docs"].first }
      let(:data_dict) { JSON.parse(dataset["validated_data_dict"]) }
      let(:datafile) { data_dict["resources"].first }

      it "includes the file id" do
        expect(datafile["id"]).to eq("ed403118-c791-4494-92f3-acd633e48178")
      end

      it "includes the file title or description if present" do
        expect(datafile["name"]).to eq(nil)
        expect(datafile["description"]).to eq("Non-consolidated performance related payments 2010-11")
      end

      it "includes the url of the file" do
        expect(datafile["url"]).to eq("https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/5722/2016987.xls")
      end

      it "includes the file format" do
        expect(datafile["format"]).to eq("XLS")
      end
    end
  end

  describe "get_organisation" do
    let(:response) { JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_organisation.json").to_s)) }
    let(:results) { described_class.get_organisation("department-for-communities-and-local-government") }
    let(:organisation) { results["response"]["docs"].first }

    before do
      allow_any_instance_of(RSolr::Client).to receive(:get).and_return(response)
    end

    it "returns one result" do
      expect(results["response"]["numFound"]).to eq(1)
    end

    it "returns the title" do
      expect(organisation["title"]).to eq("Ministry of Housing, Communities and Local Government")
    end

    it "returns the name" do
      expect(organisation["name"]).to eq("department-for-communities-and-local-government")
    end

    context "contact information" do
      it "returns the foi-email if available" do
        expect(organisation["extras_foi-email"]).to eq("foirequests@communities.gsi.gov.uk")
      end

      it "returns the foi-name if available" do
        expect(organisation["extras_foi-name"]).to eq("DCLG FOI enquiries")
      end

      it "returns the contact-email if available" do
        expect(organisation["extras_contact-email"]).to eq("http://forms.communities.gov.uk/")
      end
    end
  end

  describe "get_organisations" do
    let(:response) { JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_organisation_titles.json").to_s)) }
    let(:results) { described_class.get_organisations }

    before do
      allow_any_instance_of(RSolr::Client).to receive(:get).and_return(response)
    end

    it "returns a list of organisation titles and slugs" do
      expect(results.count).to eq(5)
      expect(results["Aberdeen City Council"]).to eq("aberdeen-city-council")
      expect(results["Aberdeenshire Council"]).to eq("aberdeenshire-council")
    end
  end
end
