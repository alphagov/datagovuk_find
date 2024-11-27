require "rails_helper"

RSpec.feature "Solr Dataset page", type: :feature do
  let(:response) { JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_dataset.json"))) }
  # let(:params) { response["response"]["docs"].first }
  # let(:dataset) { SolrDataset.new(params) } # Make this a factory

  let(:org_response) { JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_organisation.json").to_s)) }
  let(:organisation) { org_response["response"]["docs"].first }
  let(:solr_response) { build(:solr_response) } # Evantually pass a modifiable dataset { build(:solr_response, docs; [dataset]) } )
  before do
    dataset = build(:solr_dataset)
    pp dataset.id
    pp dataset.name
    # pp "RESPONSE FROM JSON"
    # pp response
    # pp "RESPONSE FROM FACTORY"
    # pp solr_response
    allow(Search::Solr).to receive(:get_by_uuid).and_return(
      solr_response
    )

    allow_any_instance_of(RSolr::Client).to receive(:get).and_return(org_response)
    # visit solr_dataset_path(dataset.id, dataset.name) # commented to test the responses
  end

  feature "Meta information" do
    scenario "Meta title tag" do
      expect(solr_response.keys).to eq(response.keys)
      expect(solr_response["response"].keys).to eq(response["response"].keys)
      expect(JSON.parse(solr_response["response"]["docs"].first["validated_data_dict"]).to_h.keys).to eq(
        JSON.parse(response["response"]["docs"].first["validated_data_dict"]).to_h.keys)

      r = JSON.parse(     response["response"]["docs"].first["validated_data_dict"]).to_h["resources"]
      s = JSON.parse(solr_response["response"]["docs"].first["validated_data_dict"]).to_h["resources"]
      expect(s).to eq(r)

      r = JSON.parse(     response["response"]["docs"].first["validated_data_dict"]).to_h.values
      s = JSON.parse(solr_response["response"]["docs"].first["validated_data_dict"]).to_h.values
      pp (r - s)
      expect(s).to eq(r)

      r = JSON.parse(     response.to_s)
      s = JSON.parse(solr_response)
      pp (r - s)
      expect(s).to eq(r)
      
      # # Failing
      #   expect(solr_response["response"]["docs"].first["validated_data_dict"]).to eq(
      #   response["response"]["docs"].first["validated_data_dict"])

      pp page.html
      expect(page)
        .to have_css('meta[name="dc:title"][content="A very interesting dataset"]', visible: false)
    end

    # scenario "Meta creator tag" do
    #   expect(page)
    #     .to have_css('meta[name="dc:creator"][content="Ministry of Housing, Communities and Local Government"]', visible: false)
    # end

    # scenario "Meta date tag" do
    #   expect(page)
    #     .to have_css('meta[name="dc:date"][content="2017-06-30"]', visible: false)
    # end

    # scenario "Meta licence tag" do
    #   expect(page)
    #     .to have_css('meta[name="dc:rights"][content="UK Open Government Licence (OGL)"]', visible: false)
    # end
  end

  # feature "Licence information" do
  #   scenario "Meta licence tag" do
  #     dataset = build :dataset, :with_ogl_licence
  #     # TODO: stub the response somehow

  #     expect(page)
  #       .to have_css('meta[name="dc:rights"][content="Open Government Licence"]',
  #                    visible: false)
  #   end

  #   scenario "Link to licence" do
  #     dataset = build :dataset, :with_ogl_licence
  #     # TODO: stub the response somehow

  #     within("section.meta-data") do
  #       expect(page)
  #         .to have_link("Open Government Licence",
  #                       href: "http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/")
  #     end
  #   end

  #   scenario "Link to licence for UK-OGL-3.0 dataset" do
  #     dataset = build :dataset, :with_ogl_uk_licence_id
  #     # TODO: stub the response somehow
  
  #     within("section.meta-data") do
  #       expect(page)
  #         .to have_link("Open Government Licence",
  #                       href: "http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/")
  #     end
  #   end

  #   scenario "Link to licence with additional info" do
  #     dataset = build :dataset, :with_ogl_licence,
  #                     licence_custom: "Special case"

  #     # TODO: stub the response somehow

  #     within("section.meta-data") do
  #       expect(page)
  #         .to have_link("View licence information",
  #                       href: "#licence-info")
  #     end

  #     within("section.dgu-licence-info") do
  #       expect(page).to have_content("Special case")
  #     end
  #   end

  #   scenario "Link to custom licence (no title, no URL)" do
  #     dataset = build :dataset, :with_custom_licence
  #     # TODO: stub the response somehow

  #     within("section.meta-data") do
  #       expect(page)
  #         .to have_content("Other Licence")

  #       expect(page)
  #         .to have_link("View licence information",
  #                       href: "#licence-info")
  #     end

  #     within("section.dgu-licence-info") do
  #       expect(page).to have_content("Special case")
  #     end
  #   end

  #   scenario "Link to custom licence brackets (no title, no URL)" do
  #     dataset = build :dataset, :with_custom_licence_brackets
  #     # TODO: stub the response somehow

  #     within("section.meta-data") do
  #       expect(page)
  #         .to have_content("Other Licence")

  #       expect(page)
  #         .to have_link("View licence information",
  #                       href: "#licence-info")
  #     end

  #     within("section.dgu-licence-info") do
  #       expect(page).to have_content("Special case")
  #     end
  #   end

  #   scenario "Link to custom licence brackets (no title, no URL)" do
  #     dataset = build :dataset, :with_custom_licence_brackets_middle
  #     # TODO: stub the response somehow

  #     within("section.meta-data") do
  #       expect(page)
  #         .to have_content("Other Licence")

  #       expect(page)
  #         .to have_link("View licence information",
  #                       href: "#licence-info")
  #     end

  #     within("section.dgu-licence-info") do
  #       expect(page).to have_content("Special case")
  #     end
  #   end

  #   scenario "Simple licence title (no URL)" do
  #     dataset = build :dataset, licence_title: "My Licence"
  #     # TODO: stub the response somehow

  #     within("section.meta-data") do
  #       expect(page)
  #         .to have_content("My Licence")
  #     end
  #   end

  #   scenario "Link to URL licence without a title" do
  #     dataset = build :dataset, licence_url: "http://licence.com"
  #     # TODO: stub the response somehow

  #     within("section.meta-data") do
  #       expect(page)
  #         .to have_link("http://licence.com",
  #                       href: "http://licence.com")
  #     end
  #   end

  #   scenario "No licence" do
  #     dataset = build :dataset
  #     # TODO: stub the response somehow

  #     within("section.meta-data") do
  #       expect(page)
  #         .to have_content("None")
  #     end
  #   end
  # end

  # feature "Metadata box" do
  #   scenario "Displays the publisher name" do
  #     expect(page).to have_content("Published by: Ministry of Housing, Communities and Local Government")
  #   end

  #   scenario "'Last updated' field displays public_updated_at" do
  #     expect(page).to have_content("Last updated: 30 June 2017")
  #   end

  #   scenario "Displays the topic if there is one" do
  #     expect(page).to have_content("Topic: Government")
  #   end

  #   scenario "Displays the summary" do
  #     expect(page).to have_content("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec euismod mauris in augue laoreet congue. Phasellus bibendum leo vel magna lacinia eleifend. Nam vitae lectus quis nulla varius faucibus id quis nibh. Nullam auctor ipsum non nunc efficitur bibendum Sed vitae ex nisi. Suspendisse posuere purus ac dui posuere, in interdum risus ornare.\nThe following files can be found on the website here:\nhttps://www.gov.uk/")
  #   end
  # end

  # feature "Show more from publisher" do
  #   scenario "Displays the link publisher's datasets" do
  #     expect(page).to have_content("More from this publisher")
  #     expect(page).to have_css("a", text: "All datasets from #{dataset.organisation.title}")
  #   end
  # end

  # scenario "Displays the search box" do
  #   expect(page).to have_css("h3", text: "Search")
  #   within("form.dgu-search-box") do
  #     expect(page).to have_content("Search")
  #   end
  # end

  # feature "Data links are present" do
  #   scenario "displays the data links heading" do
  #     expect(page).to have_css("h2", text: "Data links")
  #   end

  #   scenario "displays the table headers" do
  #     expect(page).to have_css("th", text: "Link to the data")
  #     expect(page).to have_css("th", text: "Format")
  #     expect(page).to have_css("th", text: "File added")
  #     expect(page).to have_css("th", text: "Data preview")
  #   end

  #   scenario "displays the list of data files" do
  #     expect(page).to have_css(".dgu-datalinks td a", count: 12)
  #   end

  #   scenario "displays the name of the data file as a link" do
  #     expect(page).to have_css("td a", text: "Non-consolidated performance related payments 2015-16 (XLS format)")
  #   end

  #   scenario "Displays the format of the file if available" do
  #     expect(page).to have_css("td", text: "XLS")
  #   end

  #   scenario "Displays the date of when the file was added" do
  #     expect(page).to have_css("td", text: "30 June 2017")
  #   end

  #   scenario "Show more and show less if more than 5 files", js: true do
  #     expect(page).to have_css("js-show-more-datafiles", count: 0)
  #     expect(page).to have_css(".js-datafile-visible", count: 5)
  #     expect(page).to have_css(".show-toggle", text: "Show more")

  #     find(".show-toggle").click

  #     expect(page).to have_css(".js-datafile-visible", count: 12)
  #     expect(page).to have_css(".show-toggle", text: "Show less")
  #   end
  # end

  # feature "Data links are not available" do
  #   let(:response) { JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_dataset_without_datafiles.json").to_s)) }
  #   let(:params) { response["response"]["docs"].first }
  #   let(:dataset) { SolrDataset.new(params) }

  #   before do
  #     allow(Search::Solr).to receive(:get_by_uuid).and_return(response)
  #     visit solr_dataset_path(dataset.id, dataset.name)
  #   end

  #   scenario "displays the data links heading" do
  #     expect(page).to have_css("h2", text: "Data links")
  #   end

  #   scenario "a message is displayed to the user" do
  #     expect(page).to have_content("This data hasn’t been released by the publisher.")
  #   end

  #   scenario "a 'not released' label is shown in the metadata box" do
  #     expect(page).to have_content("Availability: Not released")
  #   end
  # end

  # feature "Contact information" do
  #   scenario "Enquiries details exist" do
  #     expect(page).to have_css("h3", text: "Enquiries")
  #     expect(page).to have_link("Contact Ministry of Housing, Communities and Local Government regarding this dataset", href: "http://forms.communities.gov.uk/")
  #   end

  #   scenario "FOI details exist" do
  #     expect(page).to have_css("h3", text: "Freedom of Information (FOI) requests")
  #     expect(page).to have_link("DCLG FOI enquiries", href: "mailto:foirequests@communities.gsi.gov.uk")
  #   end
  # end

  # feature "Supporting documents" do
  #   scenario "Additional links are available" do
  #     expect(page).to have_css(".docs td a", count: 2)
  #   end

  #   scenario "displays the table headers" do
  #     expect(page).to have_css(".docs th", text: "Link to the document")
  #     expect(page).to have_css(".docs th", text: "Format")
  #     expect(page).to have_css(".docs th", text: "Date added")
  #   end

  #   scenario "displays the name of the data file as a link" do
  #     expect(page).to have_css(".docs td a", text: "Technical specification")
  #   end

  #   scenario "displays a placeholder name for a data file if it isn't provided" do
  #     expect(page).to have_css(".docs td a", text: "No name specified")
  #   end

  #   scenario "Displays the format of the file if available" do
  #     expect(page).to have_css(".docs td", text: "HTML")
  #   end

  #   scenario "Displays the N/A for format of the file if not provided" do
  #     expect(page).to have_css(".docs td", text: "N/A")
  #   end

  #   scenario "Displays the date of when the file was added" do
  #     expect(page).to have_css(".docs td", text: "02 July 2020")
  #   end
  # end

  # feature "Custom licence" do
  #   scenario "Does not display the title" do
  #     expect(page).to_not have_css("section.dgu-licence-info h2", text: "Licence information")
  #   end

  #   scenario "Does not show licence information" do
  #     expect(page).to_not have_css("section.dgu-licence-info")
  #   end
  # end

  # feature "Additional information" do
  #   scenario "does not display title" do
  #     expect(page).to_not have_css(".dgu-additional-info h2", text: "Additional information")
  #   end

  #   scenario "Does not display link to expand information" do
  #     expect(page).to_not have_css(".dgu-additional-info .summary", text: "View additional metadata")
  #   end

  #   scenario "Does not display list of information" do
  #     expect(page).to_not have_css(".dgu-deflist")
  #   end
  # end

  # feature "Publisher edit link" do
  #   scenario "Displays the title" do
  #     expect(page).to have_css("h2", text: "Edit this dataset")
  #   end

  #   scenario "Displays sign in message" do
  #     expect(page).to have_css("p", text: "You must have an account for this publisher on data.gov.uk to make any changes to a dataset.")
  #   end

  #   scenario "Displays sign in button" do
  #     expect(page).to have_link("Sign in", href: "/dataset/edit/a-very-interesting-dataset")
  #   end
  # end

  # feature "Inspire dataset" do
  #   let(:response) { JSON.parse(File.read(Rails.root.join("spec/fixtures/solr_inspire_dataset.json").to_s)) }

  #   feature "Custom licence" do
  #     scenario "Displays title if present" do
  #       expect(page).to have_css("section.dgu-licence-info h2", text: "Licence information")
  #     end

  #     scenario "Displays licence information if present" do
  #       expect(page).to have_css("section.dgu-licence-info", text: "Licence information\nUnder the OGL, Land Registry permits you to use the data for commercial or non-commercial purposes. \\n(a) use the polygons (including the associated geometry, namely x,y co-ordinates); or\\Ordnance Survey Public Sector End User Licence - INSPIRE (http://www.ordnancesurvey.co.uk/business-and-government/public-sector/mapping-agreements/inspire-licence.html)")
  #     end
  #   end

  #   feature "Additional information" do
  #     scenario "Displays title" do
  #       expect(page).to have_css(".dgu-additional-info h2", text: "Additional information")
  #     end

  #     scenario "Displays link to expand information" do
  #       expect(page).to have_css(".dgu-additional-info .summary", text: "View additional metadata")
  #     end

  #     scenario "Displays date added to data.gov.uk" do
  #       expect(page).to have_css(".dgu-additional-info", text: "Added to data.gov.uk")
  #       expect(page).to have_css(".dgu-additional-info", text: "2020-12-14")
  #     end

  #     scenario "Displays access constraints" do
  #       expect(page).to have_css(".dgu-additional-info", text: "Access contraints")
  #       expect(page).to have_css(".dgu-additional-info", text: "Not specified")
  #     end

  #     scenario "Displays harvest GUID" do
  #       expect(page).to have_css(".dgu-additional-info", text: "Harvest GUID")
  #       expect(page).to have_css(".dgu-additional-info", text: "3df58f2f-a13e-46e9-a657-f532f7ad2fc1")
  #     end

  #     scenario "Displays extent" do
  #       expect(page).to have_css(".dgu-additional-info", text: "Extent")
  #       expect(page).to have_css(".dgu-additional-info", text: "Latitude: 55.80° to ° Longitude: -6.33° to 1.78°")
  #     end

  #     scenario "Displays spatial reference" do
  #       expect(page).to have_css(".dgu-additional-info", text: "Spatial reference")
  #       expect(page).to have_css(".dgu-additional-info", text: "http://www.opengis.net/def/crs/EPSG/0/27700")
  #     end

  #     scenario "Displays dataset reference date" do
  #       expect(page).to have_css(".dgu-additional-info", text: "Dataset reference date")
  #       expect(page).to have_css(".dgu-additional-info", text: "2020-12-29 (publication)")
  #     end

  #     scenario "Displays frequency of update" do
  #       expect(page).to have_css(".dgu-additional-info", text: "Frequency of update")
  #       expect(page).to have_css(".dgu-additional-info", text: "monthly")
  #     end

  #     scenario "Displays responsible party" do
  #       expect(page).to have_css(".dgu-additional-info", text: "Responsible party")
  #       expect(page).to have_css(".dgu-additional-info", text: "HM Land Registry (pointOfContact)")
  #     end

  #     scenario "Displays ISO 19139 resource type" do
  #       expect(page).to have_css(".dgu-additional-info", text: "ISO 19139 resource type")
  #       expect(page).to have_css(".dgu-additional-info", text: "dataset")
  #     end

  #     scenario "Displays metadata language" do
  #       expect(page).to have_css(".dgu-additional-info", text: "Metadata language")
  #       expect(page).to have_css(".dgu-additional-info", text: "eng")
  #     end

  #     scenario "Contains a link to original source INSPIRE XML" do
  #       expect(page).to have_xpath("//a[@href='/api/2/rest/harvestobject/d35b1574-9823-4fbc-80c0-cd1cc3b84bea/xml']", visible: :all)
  #     end

  #     scenario "Contains a link to HTML rendering of INSPIRE HTML" do
  #       expect(page).to have_xpath("//a[@href='/api/2/rest/harvestobject/d35b1574-9823-4fbc-80c0-cd1cc3b84bea/html']", visible: :all)
  #     end
  #   end

  #   feature "Publisher edit link" do
  #     scenario "Does not display the title" do
  #       expect(page).to_not have_css("h2", text: "Edit this dataset")
  #     end

  #     scenario "Does not display the sign in message" do
  #       expect(page).to_not have_css("p", text: "You must have an account for this publisher on data.gov.uk to make any changes to a dataset.")
  #     end

  #     scenario "Does not display the sign in button" do
  #       expect(page).to_not have_link("Sign in", href: "/dataset/edit/performance-related-pay-department-for-communities-and-local-government")
  #     end
  #   end
  # end
end
