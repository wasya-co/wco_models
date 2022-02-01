
FactoryBot.define do

  # alphabetized : )

  factory :city do
    name { 'City' }
    cityname { 'CityName' }
  end

  factory :tag, class: Tag do
    name { 'tag-name' }
  end

  factory :user do
    sequence :email do |n|
      "some-#{n}@email.com"
    end
    password { 'some-password' }
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
