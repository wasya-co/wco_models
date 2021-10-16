
FactoryBot.define do

  factory :user_profile, :class => IshModels::UserProfile do
    email { 'test@email.com' }
  end

  factory :tag, class: Tag do
    name { 'tag-name' }
  end

end
