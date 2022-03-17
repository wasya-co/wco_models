
## @TODO: this is copy-pasted *in part* from ish_models, should be in one place really.
## should convert location of factories across gems

FactoryBot.define do

  sequence :cityname do |n|
    "cityname-#{n}"
  end

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

  factory :admin, parent: :user do
    email { generate(:email) }
    transient do
      role_name { 'admin' }
    end
    # after :build do |u, opts|
    #   u.profile ||= create(:profile, email: u.email, user: u, role_name: opts.role_name)
    # end
  end

  factory :city do
    name { 'City' }
    cityname { generate(:cityname) }
  end

  factory :gallery do
    name { generate(:slug) }
    slug { generate(:slug) }
    is_trash { false }
    is_public { true }
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
      marker.image           ||= create :image_asset
      marker.destination     ||= Gameui::Map.where( slug: marker.slug ).first || create(:map)
      marker.creator_profile ||= create(:user).profile
    end
  end

  factory :newsitem do
  end

  factory :photo do
  end

  factory :profile, aliases: [ :user_profile ], :class => Ish::UserProfile do
    email { generate(:email) }
    after :build do |doc|
      doc.user ||= create(:user)
    end
  end

  factory :premium_purchase, aliases: [ :purchase ], class: Gameui::PremiumPurchase do
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

    transient do
      role_name { 'guy' }
    end

    after :build do |u, opts|
      u.profile ||= create(:profile, email: u.email, user: u, role_name: opts.role_name)
    end
  end

  factory :video do
    name { 'some-name' }
    youtube_id { 'some-youtube-id' }
  end


end
