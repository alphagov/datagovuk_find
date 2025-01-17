FactoryBot.define do
  factory :solr_dataset, class: SolrDataset do
    id { "420932c7-e6f8-43ea-adc5-3141f757b5cb" }
    name { "a-very-interesting-dataset" }
    title { "A very interesting dataset" }
    summary { "Lorem ipsum dolor sit amet." }
    public_updated_at { "2017-06-30T09:08:37.040Z" }
    topic { "government" }
    licence_title { "UK Open Government Licence (OGL)" }
    licence_url { "http://reference.data.gov.uk/id/open-government-licence" }
    licence_code { "uk-ogl" }
    contact_email { "" }
    contact_name { "" }
    foi_name { "" }
    foi_email { "" }
    foi_web { "" }
    licence_custom { "" }
    inspire_dataset { nil }
    harvested { false }
    validated_data_dict do
      JSON.dump({
        "license_title" => "UK Open Government Licence (OGL)",
        "license_url" => "http://reference.data.gov.uk/id/open-government-licence",
        "license_id" => "uk-ogl",
        "organization" => {
          "id" => "48f370c9-7ab9-4550-9722-8c9477020fc7",
          "name" => "department-for-communities-and-local-government",
          "title" => "Ministry of Housing, Communities and Local Government",
          "type" => "organization",
          "description" => "The Ministry of Housing, Communities and Local Government's (formerly the Department for Communities and Local Government) job is to create great places to live and work, and to give more power to local people to shape what happens in their area.",
          "created" => "2012-06-27T14:48:38.548677",
          "is_organization" => true,
          "approval_status" => "pending",
          "state" => "active",
        },
        "resources" => [
          { "resource-type" => "file", "url" => "http://example.com/file.csv" },
        ],
        "extras" => [],
      })
    end

    organization { build(:organisation) }

    initialize_with do
      SolrDataset.new(attributes.stringify_keys)
    end
  end
end
