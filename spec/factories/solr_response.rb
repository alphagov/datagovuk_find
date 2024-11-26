FactoryBot.define do
  factory :solr_response, class: Hash do
    # docs { [] }

    response { attributes_for(:response).stringify_keys }

    # transient do
    #   docs { [solr_dataset] }
    # end

    initialize_with { attributes.stringify_keys }
  end

  factory :response, class: Hash do
    numFound { 1 }
    start { 0 }
    numFoundExact { true }
    docs { [attributes_for(:solr_dataset).stringify_keys] }

    initialize_with { attributes.stringify_keys }
  end

  factory :solr_dataset, class: SolrDataset do
    id { "420932c7-e6f8-43ea-adc5-3141f757b5cb" } # { SecureRandom.uuid }
    name { "a-very-interesting-dataset" }
    title { "A very interesting dataset" }
    notes { "Lorem ipsum dolor sit amet" }
    metadata_modified { "2017-06-30T09:08:37.040Z" }
    metadata_created { "2011-10-27T13:29:52.056Z" }
    organization { "department-for-communities-and-local-government" }
    add_attribute("extras_theme-primary") { "government" }

    validated_data_dict { build(:validated_data_dict) } # build because it's JSON

    # summary { notes }
    # public_updated_at { metadata_modified }
    # harvested { false }
    # organisation { build :org }
    # docs { [] }
    # datafiles { [] }
    # schema_id { "2d5b1042-0799-4ceb-9075-8307f90e877c" }

    trait :inspire do
      inspire_dataset do
        { "bbox_north_lat" => "1.0",
          "bbox_east_long" => "1.0",
          "bbox_south_lat" => "2.0",
          "bbox_west_long" => "2.0",
          "harvest_object_id" => 1234 }
      end

      datafiles { [build(:datafile, :raw, format: "WMS")] }
    end

    # trait :unrelated do
    #   title { "Unrelated" }
    #   licence { "unrelated" }
    #   summary { "Unrelated" }
    #   description { "Unrelated" }
    #   location1 { "Unrelated" }
    #   location2 { "Unrelated" }
    #   organisation { build :organisation, :raw, :unrelated }
    #   datafiles { [build(:datafile, :raw, :unrelated)] }
    #   topic { build :topic, :unrelated }
    # end

    # trait :with_datafile do
    #   datafiles { [build(:datafile, :raw)] }
    # end

    # trait :with_topic do
    #   "extras_theme-primary" { "government" },
    # end

    trait :with_ogl_licence do
      licence_code { "uk-ogl" }
      licence_url { "http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/" }
      licence_title { "Open Government Licence" }
    end

    trait :with_ogl_uk_licence_id do
      licence_code { "OGL-UK-3.0" }
      licence_title { "OGL-UK-3.0" }
    end

    trait :with_custom_licence do
      licence_custom { "Special case" }
    end

    trait :with_custom_licence_brackets do
      licence_custom { '["Special case"]' }
    end

    trait :with_custom_licence_brackets_middle do
      licence_custom { "Special case, [2019]." }
    end

    initialize_with { SolrDataset.new(attributes.stringify_keys) }
  end

  factory :validated_data_dict, class: Hash do
    # author { nil }
    # author_email { nil }
    add_attribute("contact-email") { "" }
    add_attribute("contact-name") { "" }
    add_attribute("contact-phone") { "" }
    add_attribute("core-dataset") { false }
    creator_user_id { "6e382fff-b824-43aa-bbd4-ebbea5a62d7d" }
    date_released { "2011-10-27" }
    date_updated { "2016-03-24" }
    add_attribute("foi-email") { "" }
    add_attribute("foi-name") { "" }
    add_attribute("foi-phone") { "" }
    add_attribute("foi-web") { "" }
    geographic_coverage { "100000: England" }
    geographic_granularity { "national" }
    id { "420932c7-e6f8-43ea-adc5-3141f757b5cb" }
    isopen { true }
    license_id { "uk-ogl" }
    license_title { "UK Open Government Licence (OGL)" }
    license_url { "http://reference.data.gov.uk/id/open-government-licence" }
    maintainer { nil }
    maintainer_email { nil }
    metadata_created { "2011-10-27T13:29:52.056625" }
    metadata_modified { "2017-06-30T09:08:37.040414" }
    name { "performance-related-pay-department-for-communities-and-local-government" }
    notes { "Publication of information on Non-consolidated Performance Related Pay (NCPRP) data for the Department for Communities and Local Government and its executive agencies in respect of the performance years 2010-11, 2011-12, 2013-14 and 2014-15.\r\n\r\nThe following files can be found on the DCLG website here:\r\n\r\nhttps://www.gov.uk/government/collections/dclg-performance-related-pay" }
    num_resources { 14 }
    num_tags { 0 }
    add_attribute("odi-certificate") do
      {
        status: "final",
        source: "Automatically awarded by ODI",
        certification_type: "automatically awarded",
        level: "bronze",
        title: "Non-consolidated Performance Related Pay - Department for Communities and Local Government",
        created_at: "2014-10-28T12:53:13Z",
        jurisdiction: "GB",
        certificate_url: "https://certificates.theodi.org/en/datasets/5922/certificate",
        badge_url: "https://certificates.theodi.org/en/datasets/5922/certificate/badge.png",
        cert_title: "Bronze level certificate"
      }
    end
    organization {  build(:org) }
    owner_org { "48f370c9-7ab9-4550-9722-8c9477020fc7" }
    add_attribute("private") { false }
    state { "active" }
    add_attribute("temporal_coverage-from") { "2010-04-01" }
    add_attribute("temporal_coverage-to") { "2015-03-31" }
    temporal_granularity { "year" }
    add_attribute("theme-primary") { "government" }
    add_attribute("theme-secondary") { ["Environment"] }
    title { "Non-consolidated Performance Related Pay - Department for Communities and Local Government" }
    type { "dataset" }
    unpublished { false }
    update_frequency { "annual" }
    url { "http://https://www.gov.uk/government/collections/dclg-performance-related-pay" }
    version { nil }
    extras do
      [
        { key: "its-dataset", value: "false" },
        { key: "register", value: "false" },
        { key: "sla", value: "" }
      ]
    end
    resources do
      [
        {
          cache_last_updated: nil,
          cache_url: nil,
          description: "Non-consolidated performance related payments 2010-11",
          format: "XLS",
          id: "ed403118-c791-4494-92f3-acd633e48178",
          last_modified: nil,
          metadata_modified: nil,
          mimetype: nil,
          mimetype_inner: nil,
          name: nil,
          package_id: "420932c7-e6f8-43ea-adc5-3141f757b5cb",
          position: 0,
          resource_type: "file",
          size: nil,
          state: "active",
          url: "https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/5722/2016987.xls",
          url_type: nil
        },
        {
          cache_last_updated: nil,
          cache_url: nil,
          description: "Non-consolidated performance related payments 2010-11 (CSV format)",
          format: "CSV",
          id: "0e1a19ab-fef2-408f-84ce-ae4e991ec56b",
          last_modified: nil,
          metadata_modified: nil,
          mimetype: nil,
          mimetype_inner: nil,
          name: nil,
          package_id: "420932c7-e6f8-43ea-adc5-3141f757b5cb",
          position: 1,
          resource_type: "file",
          size: nil,
          state: "active",
          url: "https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/5723/2016992.csv",
          url_type: nil
        },
        {
          cache_last_updated: nil,
          cache_url: nil,
          created: "2012-12-20T10:09:01.499730",
          description: "Non-consolidated performance related payments 2011-12",
          format: "XLS",
          id: "404b765a-f66f-4cb0-9a23-788c941d5a47",
          last_modified: nil,
          metadata_modified: "2012-12-20T10:09:01.499730",
          mimetype: nil,
          mimetype_inner: nil,
          name: nil,
          package_id: "420932c7-e6f8-43ea-adc5-3141f757b5cb",
          position: 2,
          resource_type: "file",
          size: nil,
          state: "active",
          url: "https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/39452/NCPRP_exercise_template_2011-12_Performance_Year_Publish.xls",
          url_type: nil
        },
        {
          cache_last_updated: nil,
          cache_url: nil,
          created: "2012-12-20T10:09:01.499752",
          description: "Non-consolidated performance related payments 2011-12 (CSV format)",
          format: "CSV",
          id: "2e529e11-5d1e-48f0-89c8-1310836a329a",
          last_modified: nil,
          metadata_modified: "2012-12-20T10:09:01.499752",
          mimetype: nil,
          mimetype_inner: nil,
          name: nil,
          package_id: "420932c7-e6f8-43ea-adc5-3141f757b5cb",
          position: 3,
          resource_type: "file",
          size: nil,
          state: "active",
          url: "https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/39453/NCPRP_exercise_template_2011-12_Performance_Year_Publish.csv",
          url_type: nil
        },
        {
          cache_last_updated: nil,
          cache_url: nil,
          created: "2014-02-27T12:29:43.822722",
          description: "Non-consolidated performance related payments 2012-13 (XLS format)",
          format: "XLS",
          id: "46abbced-dd0f-45c4-b15e-72d94fbce62e",
          last_modified: nil,
          metadata_modified: "2014-02-27T12:29:43.822722",
          mimetype: nil,
          mimetype_inner: nil,
          name: nil,
          package_id: "420932c7-e6f8-43ea-adc5-3141f757b5cb",
          position: 4,
          resource_type: "file",
          size: nil,
          state: "active",
          url: "https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/285255/NCPRP_template_for_publication_2013.xls",
          url_type: nil
        },
        {
          cache_last_updated: nil,
          cache_url: nil,
          created: "2014-02-27T12:29:43.822741",
          description: "Non-consolidated performance related payments 2012-13 (CSV format)",
          format: "CSV",
          id: "64f94d94-cbba-4dd6-a5db-593604f3451c",
          last_modified: nil,
          metadata_modified: "2014-02-27T12:29:43.822741",
          mimetype: nil,
          mimetype_inner: nil,
          name: nil,
          package_id: "420932c7-e6f8-43ea-adc5-3141f757b5cb",
          position: 5,
          resource_type: "file",
          size: nil,
          state: "active",
          url: "https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/285256/NCPRP_data_collection_CSV_2013.csv",
          url_type: nil
        },
        {
          cache_last_updated: nil,
          cache_url: nil,
          created: "2016-03-24T15:53:39.464970",
          description: "Non-consolidated performance related payments 2013-14 (XLS format)",
          format: "XLS",
          hash: "",
          id: "8f923422-a9b5-475c-a57d-df85ef796b24",
          last_modified: nil,
          metadata_modified: "2016-03-24T15:53:39.464970",
          mimetype: nil,
          mimetype_inner: nil,
          name: nil,
          package_id: "420932c7-e6f8-43ea-adc5-3141f757b5cb",
          position: 6,
          resource_type: "file",
          size: nil,
          state: "active",
          url: "https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/414725/NCPRP_template_for_publication_2014.xls",
          url_type: nil
        },
        {
          cache_last_updated: nil,
          cache_url: nil,
          created: "2016-03-24T15:53:39.464998",
          description: "Non-consolidated performance related payments 2013-14 (CSV format)",
          format: "CSV",
          hash: "",
          id: "9ce8b540-cd45-4c77-ad18-e26752987200",
          last_modified: nil,
          metadata_modified: "2016-03-24T15:53:39.464998",
          mimetype: nil,
          mimetype_inner: nil,
          name: nil,
          package_id: "420932c7-e6f8-43ea-adc5-3141f757b5cb",
          position: 7,
          resource_type: "file",
          size: nil,
          state: "active",
          url: "https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/414726/NCPRP_template_for_publication_2014.csv",
          url_type: nil
        },
        {
          cache_last_updated: nil,
          cache_url: nil,
          created: "2016-03-24T15:53:39.465009",
          description: "Non-consolidated performance related payments 2014-15 (XLS format)",
          format: "XLS",
          hash: "",
          id: "05ad2563-fea3-4c74-bf62-829b52ef834a",
          last_modified: nil,
          metadata_modified: "2016-03-24T15:53:39.465009",
          mimetype: nil,
          mimetype_inner: nil,
          name: nil,
          package_id: "420932c7-e6f8-43ea-adc5-3141f757b5cb",
          position: 8,
          resource_type: "file",
          size: nil,
          state: "active",
          url: "https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/510778/DCLG_non-consolidated_performance_related_pay_2014-15.xlsx",
          url_type: nil
        },
        # {
        #   cache_last_updated: nil,
        #   cache_url: nil,
        #   created: "2016-03-24T15:53:39.465019",
        #   description: "Non-consolidated performance related payments 2014-15 (CSV format)",
        #   format: "CSV",
        #   hash: "",
        #   id: "b2ed285e-23f2-4ec2-9f6c-d03908778a40",
        #   last_modified: nil,
        #   metadata_modified: "2016-03-24T15:53:39.465019",
        #   mimetype: nil,
        #   mimetype_inner: nil,
        #   name: nil,
        #   package_id: "420932c7-e6f8-43ea-adc5-3141f757b5cb",
        #   position: 9,
        #   resource_type: "file",
        #   size: nil,
        #   state: "active",
        #   url: "https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/510779/DCLG_non-consolidated_performance_related_pay_2014-15.csv",
        #   url_type: nil
        # },
      ]
    end
    tags { [] }
    groups { [] }
    relationships_as_subject { [] }
    relationships_as_object { [] }

    initialize_with { attributes.to_json } # Add a spece before null in JSON
  end

  factory :org, class: Hash do
    id { "48f370c9-7ab9-4550-9722-8c9477020fc7" }
    name { "department-for-communities-and-local-government" }
    title { "Ministry of Housing, Communities and Local Government" }
    type { "organization" }
    description { "The Ministry of Housing, Communities and Local Government's (formerly the Department for Communities and Local Government) job is to create great places to live and work, and to give more power to local people to shape what happens in their area.\r\n\r\nhttps://www.gov.uk/government/organisations/ministry-of-housing-communities-and-local-government\r\n" }
    image_url { "" }
    created { "2012-06-27T14:48:38.548677" }
    is_organization { true }
    approval_status { "pending" }
    state { "active" }

    initialize_with { attributes.stringify_keys }
  end
end
