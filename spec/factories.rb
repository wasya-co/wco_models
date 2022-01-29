
FactoryBot.define do

  # alphabetized : )

  factory :city do
    name { 'City' }
    cityname { 'CityName' }
  end

  factory :option_watch, class: Warbler::OptionWatch do
    contractType { 'PUT' }
    strike { 100 }
    ticker { 'SPY' }
    date { '2021-01-01' }
    after :build do |doc|
      doc.profile = create(:user_profile)
    end
  end

  factory :tag, class: Tag do
    name { 'tag-name' }
  end

  factory :user do
    sequence :email do |n|
      "some-#{n}@email.com"
    end
  end

  factory :user_profile, :class => Ish::UserProfile do
    sequence :email do |n|
      "test-#{n}@email.com"
    end
    name { 'some-name' }
    after :build do |doc|
      doc.user = create(:user)
    end
  end

  factory :video do
    description { 'some-description' }
  end

end
