FactoryBot.define do
  factory :datafile do
    id { 1 }
    name { "Name" }
    url { "http://example.com" }
    format { "CSV" }
    uuid { SecureRandom.uuid }

    trait :unrelated do
      format { "unrelated" }
    end

    trait :raw do
      initialize_with { attributes.stringify_keys }
    end

    initialize_with { Datafile.new(attributes.stringify_keys) }
  end

  factory :solr_datafile, class: SolrDataset do
    id { 1 }
    name { "Name" }
    url { "http://example.com" }
    format { "CSV" }

    trait :raw do
      initialize_with { attributes.stringify_keys }
    end

    initialize_with { Datafile.new(attributes.stringify_keys) }
  end
end
