require "rails_helper"

RSpec.describe Search::Solr do
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

    it "returns a response if q param is missing" do
      expect { described_class.search({}) }.not_to raise_error
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

    context "when the cache is empty" do
      it "queries Solr and stores the result in the cache" do
        expect(Rails.cache).to receive(:fetch).with(
          "organisation/department-for-communities-and-local-government",
          expires_in: 10.minutes,
        ).and_yield
        expect(Search::Solr.client).to receive(:get).and_return(response)

        organisation = Search::Solr.get_organisation("department-for-communities-and-local-government")

        expect(organisation["response"]["docs"].first["title"]).to eq("Ministry of Housing, Communities and Local Government")
      end
    end

    context "when the cache is already populated" do
      it "does not query Solr again and returns the cached result" do
        cached_organisation = {
          "title" => "Ministry of Housing, Communities and Local Government",
          "name" => "department-for-communities-and-local-government",
        }
        allow(Rails.cache).to receive(:fetch).with(
          "organisation/department-for-communities-and-local-government",
          expires_in: 10.minutes,
        ).and_return(cached_organisation)
        expect(Search::Solr.client).not_to receive(:get)

        organisation = Search::Solr.get_organisation("department-for-communities-and-local-government")

        expect(organisation).to eq(cached_organisation)
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

    context "when the cache is empty" do
      it "queries Solr and stores the result in the cache" do
        expect(Rails.cache).to receive(:fetch).with("organisations", expires_in: 10.minutes).and_yield
        expect(Search::Solr.client).to receive(:get).and_return(response)

        organisations = Search::Solr.get_organisations

        expect(organisations.count).to eq(5)
        expect(organisations["Aberdeen City Council"]).to eq("aberdeen-city-council")
      end
    end

    context "when the cache is already populated" do
      it "does not query Solr again and returns the cached result" do
        cached_organisations = { "Aberdeen City Council" => "aberdeen-city-council",
                                 "Aberdeenshire Council" => "aberdeenshire-council" }
        allow(Rails.cache).to receive(:fetch).with("organisations", expires_in: 10.minutes).and_return(cached_organisations)
        expect(Search::Solr.client).not_to receive(:get)

        organisations = Search::Solr.get_organisations

        expect(organisations).to eq(cached_organisations)
      end
    end
  end

  describe "#query_solr" do
    let(:response) { File.read(Rails.root.join("spec/fixtures/solr_response.json").to_s) }
    let(:results) { described_class.search("q" => "") }
    let(:requested_fields) { %w[id name title organization notes metadata_modified extras_theme-primary validated_data_dict] }

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

    it "includes the requested fields from solr" do
      dataset = results["response"]["docs"].first
      requested_fields.each do |field|
        expect(dataset[field]).not_to be_empty
      end
    end
  end

  describe "#query_solr_with_facets" do
    let(:response) { File.read(Rails.root.join("spec/fixtures/solr_response_with_facets.json").to_s) }
    let(:results) { described_class.search("q" => "interesting dataset") }
    let(:requested_fields) { %w[id name title organization notes metadata_modified extras_theme-primary validated_data_dict] }

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

    it "includes the requested fields from solr" do
      dataset = results["response"]["docs"].first
      requested_fields.each do |field|
        expect(dataset[field]).not_to be_empty
      end
    end

    it "includes the datasets' organisations" do
      org_facets = results["facet_counts"]["facet_fields"]["organization"]
      expect(org_facets[0]).to eq("department-for-communities-and-local-government")
      expect(org_facets[1]).to eq(1)
      expect(org_facets[2]).to eq("mole-valley-district-council")
      expect(org_facets[3]).to eq(1)
    end

    it "includes the datasets' (tokenized) topics" do
      topic_facets = results["facet_counts"]["facet_fields"]["extras_theme-primary"]
      expect(topic_facets[0]).to eq("societi")
      expect(topic_facets[1]).to eq(18)
      expect(topic_facets[2]).to eq("health")
      expect(topic_facets[3]).to eq(9)
    end

    it "includes the datasets' formats" do
      topic_facets = results["facet_counts"]["facet_fields"]["res_format"]
      expect(topic_facets[0]).to eq("CSV")
      expect(topic_facets[1]).to eq(4)
      expect(topic_facets[2]).to eq("ZIP")
      expect(topic_facets[3]).to eq(2)
    end
  end

  describe ".build_term_query" do
    it "returns special syntax that requests all documents in the index, if q param is missing" do
      term_query = described_class.build_term_query(
        "",
      )

      expect(term_query).to eq("*:*")
    end

    it "returns a solr query for multiple search terms" do
      term_query = described_class.build_term_query(
        "animal health",
      )

      expect(term_query).to eq(
        "(title:(animal health)^2 OR notes:(animal health)) AND NOT site_id:dgu_organisations",
      )
    end

    it "returns a solr query for exact phrase search (in quotes)" do
      term_query = described_class.build_term_query(
        "\"animal health\"",
      )

      expect(term_query).to eq(
        "(title:(\"animal health\")^2 OR notes:(\"animal health\")) AND NOT site_id:dgu_organisations",
      )
    end

    it "returns a solr query for multiple search terms including exact phrase search (in quotes)" do
      term_query = described_class.build_term_query(
        "\"animal health\" dogs",
      )

      expect(term_query).to eq(
        "(title:(\"animal health\" dogs)^2 OR notes:(\"animal health\" dogs)) AND NOT site_id:dgu_organisations",
      )
    end

    it "returns a solr query for search terms without stop words" do
      term_query = described_class.build_term_query(
        "organogram of staff roles & salaries",
      )

      expect(term_query).to eq(
        "(title:(organogram staff roles salaries)^2 OR notes:(organogram staff roles salaries)) AND NOT site_id:dgu_organisations",
      )
    end

    it "returns a solr query for search phrases including stop words" do
      term_query = described_class.build_term_query(
        "\"organogram of staff roles & salaries\"",
      )

      expect(term_query).to eq(
        "(title:(\"organogram of staff roles & salaries\")^2 OR notes:(\"organogram of staff roles & salaries\")) AND NOT site_id:dgu_organisations",
      )
    end

    it "raises an error if query is empty after processing" do
      expect {
        described_class.build_term_query(
          "the or",
        )
      }.to raise_error(Search::Solr::NoSearchTermsError)
    end
  end

  describe ".build_filter_query" do
    it "includes active datasets filter" do
      filter_query = described_class.build_filter_query({ filters: {} })

      expect(filter_query).to eq(["state:active type:dataset"])
    end
  end

  describe ".format_filter" do
    it "returns solr filter query with all format variations for a main format" do
      expect(described_class.format_filter("CSV")).to eq(
        "res_format:\"CSV\"ORres_format:\".csv\"ORres_format:\"csv\"ORres_format:\"CSV \"ORres_format:\"csv.\"ORres_format:\".CSV\"ORres_format:\"https://www.iana.org/assignments/media-types/text/csv\"",
      )
    end

    it "returns negative solr filter query for Other formats" do
      query_string =
        "-res_format:\"CSV\"-res_format:\".csv\"-res_format:\"csv\"-res_format:\"CSV \"-res_format:\"csv.\"-res_format:\".CSV\"-res_format:\"https://www.iana.org/assignments/media-types/text/csv\"" \
        "-res_format:\"Esri REST\"-res_format:\"ESRI REST API\"" \
        "-res_format:\"GeoJSON\"-res_format:\"geojson\"" \
        "-res_format:\"HTML\"-res_format:\"html\"-res_format:\".html\"" \
        "-res_format:\"JSON\"-res_format:\"json1.0\"-res_format:\"json2.0\"-res_format:\"https://www.iana.org/assignments/media-types/application/json\"" \
        "-res_format:\"KML\"-res_format:\"kml\"" \
        "-res_format:\"PDF\"-res_format:\".pdf\"-res_format:\"pdf\"" \
        "-res_format:\"SHP\"" \
        "-res_format:\"WFS\"-res_format:\"OGC WFS\"-res_format:\"ogc wfs\"-res_format:\"wfs\"" \
        "-res_format:\"WMS\"-res_format:\"OGC WMS\"-res_format:\"ogc wfs\"-res_format:\"wms\"" \
        "-res_format:\"XLS\"-res_format:\"xls\"-res_format:\".xls\"" \
        "-res_format:\"XML\"" \
        "-res_format:\"ZIP\"-res_format:\"Zip\"-res_format:\"https://www.iana.org/assignments/media-types/application/zip\"-res_format:\"zip\"-res_format:\".zip\""

      expect(described_class.format_filter("Other")).to eq(query_string)
    end

    it "returns solr query if format is not supported by the filter in the GUI" do
      expect(described_class.format_filter("RDF")).to eq(
        "res_format:\"RDF\"",
      )
    end
  end

  describe ".licence_filter" do
    it "returns solr filter query with all variations of Open Government Licence" do
      expect(described_class.licence_filter("uk-ogl")).to eq(
        "license_id:(uk-ogl OGL-UK-* ogl)",
      )
    end

    it "returns solr filter query for other licences" do
      expect(described_class.licence_filter("other-nc")).to eq(
        "license_id:\"other-nc\"",
      )
    end
  end
end
