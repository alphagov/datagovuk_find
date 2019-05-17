FactoryBot.define do
  factory :dataset do
    name 'default-dataset-name'
    legacy_name 'default-dataset-name'
    title 'Default dataset title'
    summary 'Ethnicity data'
    description 'Ethnicity data'
    location1 'London'
    location2 'Southwark'
    location3 ''
    frequency 'monthly'
    published_date '2013-08-31T005615.435Z'
    harvested false
    created_at '2013-08-31T005615.435Z'
    last_updated_at '2017-07-24T144725.975Z'
    contact_name ''
    contact_email ''
    uuid SecureRandom.uuid
    notes ''
    public_updated_at Time.now.iso8601
    organisation { build :organisation, :raw }
    docs []
    datafiles []
    schema_id '2d5b1042-0799-4ceb-9075-8307f90e877c'

    trait :inspire do
      inspire_dataset do
        { 'bbox_north_lat' => '1.0', 'bbox_east_long' => '1.0',
          'bbox_south_lat' => '2.0', 'bbox_west_long' => '2.0',
          'harvest_object_id' => 1234 }
      end

      datafiles { [build(:datafile, :raw, format: 'WMS')] }
    end

    trait :unrelated do
      title 'Unrelated'
      licence 'unrelated'
      summary 'Unrelated'
      description 'Unrelated'
      location1 'Unrelated'
      location2 'Unrelated'
      organisation { build :organisation, :raw, :unrelated }
      datafiles { [build(:datafile, :raw, :unrelated)] }
      topic { build :topic, :unrelated }
    end

    trait :with_datafile do
      datafiles { [build(:datafile, :raw)] }
    end

    trait :with_topic do
      topic { build :topic }
    end

    trait :with_ogl_licence do
      licence_code 'uk-ogl'
      licence_url 'http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/'
      licence_title 'Open Government Licence'
    end

    trait :with_custom_licence do
      licence_custom 'Special case'
    end

    initialize_with { Dataset.new(attributes.stringify_keys) }
  end
end
