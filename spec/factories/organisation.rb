FactoryBot.define do
  factory :organisation do
    id 582
    name 'ministry-of-defence'
    title 'Ministry of Defence'
    description 'We protect the security independence and interests of our country at home and abroad. We work with our allies and partners whenever possible. Our aim is to ensure that the armed forces have the training equipment and support necessary for their work and that we keep within budget.\r\n\r\nMOD is a ministerial department supported by 28 agencies and public bodies.\r\n\r\nhttps//www.gov.uk/government/organisations/ministry-of-defence\r\n\r\n'
    abbreviation 'MOD'
    replace_by '[]'
    contact_email ''
    contact_phone ''
    contact_name ''
    foi_email ''
    foi_phone ''
    foi_name ''
    foi_web ''
    category 'ministerial-department'
    organisation_user_id ''
    created_at '2017-07-24T125426.087Z'
    updated_at '2017-07-24T125426.087Z'
    uuid '5db6e904-ea2f-42a7-93bd-a61da059246f'
    active true
    org_type 'central-government'
    ancestry ''
    govuk_content_id SecureRandom.uuid

    trait :non_ministerial_department do
      category 'non-ministerial-department'
      title 'Forestry Commission'
    end

    trait :local_council do
      category 'local-council'
      title 'Plymouth City Council'
    end

    trait :non_departmental_public_body do
      category 'executive-ndpb'
      title 'English Heritage'
    end

    trait :unrelated do
      name 'unrelated'
      title 'Unrelated'
    end

    trait :raw do
      initialize_with { attributes.stringify_keys }
    end

    initialize_with { Organisation.new(attributes.stringify_keys) }
  end
end
