FactoryBot.define do
  factory :topic, class: Hash do
    id 1
    name 'government'
    title 'Government'

    trait :unrelated do
      name 'unrelated'
      title 'Unrelated'
    end

    initialize_with { attributes.stringify_keys }
  end
end
