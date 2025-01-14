FactoryBot.define do
  factory :solr_datafile, class: SolrDataset do
    id { 1 }
    name { "Name" }
    url { "http://example.com" }
    created_at { Time.zone.now - 1.day }
    format { "CSV" }

    initialize_with { SolrDatafile.new(attributes.stringify_keys, attributes[:created_at]) }
  end
end
