
FactoryBot.define do
  sequence :email do |n|
    "some-#{n}@email.com"
  end

  sequence :slug do |n|
    "slug-#{n}"
  end

  # alphabetized : )

  factory :city do
    name { 'City' }
    cityname { 'CityName' }
  end

  ## MODIFIED copy-pasted from ish_manager
  factory :image_asset, class: Ish::ImageAsset do
    image { File.new(File.join('data', 'image.jpg')) }
  end

  ## MODIFIED copy-pasted from ish_manager
  factory :marker, class: Gameui::Marker do
    name { 'name' }
    slug { generate(:slug) }
    item_type { ::Gameui::Marker::ITEM_TYPES[0] }
    after :build do |marker|
      marker.map ||= create(:map)
      marker.image = create :image_asset
    end
  end

  ## copy-pasted from ish_manager
  factory :map, class: Gameui::Map do
    name { 'name' }
    slug { generate(:slug) }
    creator_profile { create(:profile) }
    after :build do |map|
      map.image = create :image_asset
    end
  end

  factory :profile, :class => Ish::UserProfile do
    email { generate(:email) }
    name { 'some-name' }
    after :build do |doc|
      doc.user = create(:user)
    end
  end

  factory :tag, class: Tag do
    name { 'tag-name' }
  end

  factory :user do
    email { generate(:email) }
    password { 'some-password' }
  end

  ## @deprecated, use :profile
  factory :user_profile, :class => Ish::UserProfile do
    email { generate(:email) }
    name { 'some-name' }
    after :build do |doc|
      doc.user = create(:user)
    end
  end

  factory :video do
    description { 'some-description' }
  end

end
