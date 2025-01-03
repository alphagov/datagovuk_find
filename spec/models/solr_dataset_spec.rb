require "rails_helper"

RSpec.describe SolrDataset do
  describe ".get_by_uuid" do
    context "dataset exists" do
      let(:response) { JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_dataset.json").to_s)) }
      let(:dataset) { described_class.get_by_uuid(uuid: "420932c7-e6f8-43ea-adc5-3141f757b5cb") }

      before do
        org_response = JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_organisation.json").to_s))
        allow(Search::Solr).to receive(:get_organisation).and_return(org_response)
        allow_any_instance_of(RSolr::Client).to receive(:get).and_return(response)
      end

      it "returns dataset with uuid" do
        expect(dataset.uuid).to eq("420932c7-e6f8-43ea-adc5-3141f757b5cb")
      end

      it "returns dataset with name" do
        expect(dataset.name).to eq("a-very-interesting-dataset")
      end

      it "returns dataset with title" do
        expect(dataset.title).to eq("A very interesting dataset")
      end

      it "returns dataset with summary (notes)" do
        expect(dataset.summary).to eq("Lorem ipsum dolor sit amet.")
      end

      it "returns dataset with last updated date" do
        expect(dataset.public_updated_at).to eq("2017-06-30T09:08:37.040Z")
      end

      it "returns dataset with formatted topic" do
        expect(dataset.topic).to eq("Government")
      end

      it "returns dataset with licence title" do
        expect(dataset.licence_title).to eq("UK Open Government Licence (OGL)")
      end

      it "returns dataset with licence url" do
        expect(dataset.licence_url).to eq("http://reference.data.gov.uk/id/open-government-licence")
      end

      it "returns dataset with licence code" do
        expect(dataset.licence_code).to eq("uk-ogl")
      end

      it "returns dataset with fomatted custom licence" do
        expect(dataset.licence_code).to eq("uk-ogl")
      end

      it "returns dataset with organisation" do
        expect(dataset.organisation).to be_an_instance_of(Organisation)
        expect(dataset.organisation.title).to eq("Ministry of Housing, Communities and Local Government")
        expect(dataset.organisation.name).to eq("department-for-communities-and-local-government")
      end

      it "returns dataset with an array of datafiles" do
        expect(dataset.datafiles.size).to eq(12)
        expect(dataset.datafiles.first).to be_an_instance_of(SolrDatafile)
        expect(dataset.datafiles.first.name).to eq("Non-consolidated performance related payments 2010-11")
      end

      it "returns dataset with array of docs" do
        expect(dataset.docs.size).to eq(2)
        expect(dataset.docs.first["name"]).to eq("Technical specification")
        expect(dataset.docs.first["url"]).to eq("https: //use-land-property-data.service.gov.uk/datasets/rfi/tech-spec")
      end
    end

    context "Dataset doesn't exist" do
      it "raises an exeption if Solr returns 404 response" do
        mock_solr_http_error(status: 404)

        expect {
          described_class.get_by_uuid(uuid: "does-not-exist")
        }.to raise_error(described_class::NotFound)
      end

      it "raises an exeption if Solr returns 400 response" do
        mock_solr_http_error(status: 400)

        expect {
          described_class.get_by_uuid(uuid: "does-not-exist")
        }.to raise_error(described_class::NotFound)
      end

      it "raises an exeption if Solr returns zero results" do
        response = { "response" => {
          "numFound" => 0,
          "docs" => [],
        } }
        allow_any_instance_of(RSolr::Client).to receive(:get).and_return(response)

        expect {
          described_class.get_by_uuid(uuid: "f3850ff3-f049-154d-8f5c-d408d6b91fb2")
        }.to raise_error(described_class::NotFound)
      end
    end
  end

  describe ".get_by_legacy_name" do
    context "dataset exists" do
      let(:response) { JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_dataset.json").to_s)) }
      let(:dataset) { described_class.get_by_legacy_name(legacy_name: "a-very-interesting-dataset") }

      before do
        org_response = JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_organisation.json").to_s))
        allow(Search::Solr).to receive(:get_organisation).and_return(org_response)
        allow_any_instance_of(RSolr::Client).to receive(:get).and_return(response)
      end

      it "returns correct dataset" do
        expect(dataset.uuid).to eq("420932c7-e6f8-43ea-adc5-3141f757b5cb")
        expect(dataset.name).to eq("a-very-interesting-dataset")
        expect(dataset.title).to eq("A very interesting dataset")
      end
    end

    context "Dataset doesn't exist" do
      it "raises an exeption if Solr returns 404 response" do
        mock_solr_http_error(status: 404)

        expect {
          described_class.get_by_legacy_name(legacy_name: "does-not-exist")
        }.to raise_error(described_class::NotFound)
      end

      it "raises an exeption if Solr returns zero results" do
        response = { "response" => {
          "numFound" => 0,
          "docs" => [],
        } }
        allow_any_instance_of(RSolr::Client).to receive(:get).and_return(response)

        expect {
          described_class.get_by_legacy_name(legacy_name: "exists-but-solr-is-unwell")
        }.to raise_error(described_class::NotFound)
      end
    end
  end

  describe "#organogram?" do
    before do
      org_response = JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_organisation.json").to_s))
      allow(Search::Solr).to receive(:get_organisation).and_return(org_response)
    end

    it "returns true if schema_id mateches those of organagram" do
      response = modified_dataset_validated_data_dict_json(
        "schema-vocabulary", "d3c0b23f-6979-45e4-88ed-d2ab59b005d0"
      )
      params = response["response"]["docs"].first
      dataset = described_class.new(params)

      expect(dataset.organogram?).to eq(true)
    end

    it "returns false if schema_id is not an organagrmam" do
      response = JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_dataset.json").to_s))
      params = response["response"]["docs"].first
      dataset = described_class.new(params)

      expect(dataset.organogram?).to eq(false)
    end
  end
end
