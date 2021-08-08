
FactoryBot.define do

  factory :user_profile, :class => IshModels::UserProfile do
    email { 'test@email.com' }
  end

end
