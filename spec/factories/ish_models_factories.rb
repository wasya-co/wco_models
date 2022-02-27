
## @TODO: this is copy-pasted *in part* from ish_models, should be in one place really.
## should convert location of factories across gems

FactoryBot.define do

  sequence :email do |n|
    "test-#{n}@email.com"
  end

  sequence :handle do |n|
    "handle-#{n}"
  end

  sequence :slug do |n|
    "slug-#{n}"
  end

  # alphabetized : )

  factory :admin do
    email { 'piousbox@gmail.com' }
    password { '1234567890' }
    after :build do |u|
      p = Ish::UserProfile.create email: 'piousbox@gmail.com', name: 'sudoer', user: u
    end
  end

  factory :city do
    name { 'City' }
    cityname { 'city' }
  end

  factory :gallery do
    name { 'xxTestxx' }
    slug { 'xxSlugxx' }
    is_trash { false }
    after :build do |g|
      g.site ||= Site.new( :domain => 'xxDomainxx', :lang => 'xxLangxx' )
      g.slug ||= name
    end
  end

  factory :image_asset, class: Ish::ImageAsset do
    image { File.new(File.join(Rails.root, 'data', 'image.jpg')) }
  end

  factory :map, class: Gameui::Map do
    name { 'name' }
    slug { generate(:slug) }
    config { "{}" }
    creator_profile { create(:profile) }
    labels { "{}" }
    after :build do |map|
      map.image = create :image_asset
    end
  end

  factory :marker, class: Gameui::Marker do
    name { 'name' }
    slug { generate(:slug) }
    item_type { ::Gameui::Marker::ITEM_TYPES[0] }
    after :build do |marker|
      marker.image = create :image_asset
    end
  end

  factory :newsitem do
  end

  factory :photo do
  end

  factory :profile, aliases: [ :user_profile ], :class => Ish::UserProfile do
    email { generate(:email) }
    id { generate(:handle) }
    after :build do |doc|
      doc.user ||= create(:user)
    end
  end

  factory :purchase, class: Gameui::PremiumPurchase do
  end

  factory :report do
    name { 'Report Name' }
  end

  factory :site do
    domain { 'domain.com' }
  end

  factory :tag do
    name { 'tag-name' }
  end

  factory :user do
    email { generate(:email) }
    password { '1234567890' }
    after :build do |u|
      u.profile ||= create(:profile, email: u.email, user: u)
    end
  end

  factory :video do
    name { 'some-name' }
    youtube_id { 'some-youtube-id' }
  end


end
