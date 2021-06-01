FactoryBot.define do
  factory :match_multi, class: "Match" do
    association :vaccination_center

    user
    campaign

    trait :confirmed do
      confirmed_at { Time.zone.now }
    end

    trait :available do
      expires_at { 1.hours.from_now }
    end
  end
end
