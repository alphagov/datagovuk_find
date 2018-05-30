FactoryBot.define do
  factory :doc do
    name 'My Doc'
    url 'http://example.com'
    format ''
    uuid SecureRandom.uuid
    created_at Time.now.iso8601

    trait :raw do
      initialize_with { attributes.stringify_keys }
    end

    initialize_with { Doc.new(attributes) }
  end
end
