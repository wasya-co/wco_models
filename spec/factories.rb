
FactoryBot.define do

  factory :city do
    name { 'City' }
    cityname { 'CityName' }
  end

  factory :user_profile, :class => Ish::UserProfile do
    email { 'test@email.com' }
  end

  factory :tag, class: Tag do
    name { 'tag-name' }
  end

  factory :video do
    description { 'some-description' }
  end

end
