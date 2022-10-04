
FactoryBot.define do

  # alphabetized : )

  sequence :email do |n|
    "test-#{n}@email.com"
  end
  sequence :handle do |n|
    "handle-#{n}"
  end
  sequence :name do |n|
    "name-#{n}"
  end
  sequence :slug do |n|
    "slug-#{n}"
  end

  factory :admin, parent: :user do
    email { generate(:email) }
    transient do
      role_name { :admin }
    end
    after :build do |u, opts|
      u.profile.role_name = opts.role_name
    end
  end

  factory :manager, parent: :user do
    email { generate(:email) }
    transient do
      role_name { :manager }
    end
    after :build do |u, opts|
      u.profile.role_name = opts.role_name
      u.confirmed_at = Time.now
    end
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
    config { "{}" }
    creator_profile { create(:profile) }
    labels { "{}" }
    name { 'name' }
    slug { generate(:slug) }
    after :build do |map|
      ## I need both: locatin_id and map.image ?! _vp_ 2022-09-17
      map.image = create(:image_asset, location_id: map.id)
    end
  end

  factory :marker, class: Gameui::Marker do
    name { generate(:name) }
    item_type { ::Gameui::Marker::ITEM_TYPES[0] }
    after :build do |marker|
      marker.creator_profile ||= create(:user).profile
      marker.destination     ||= create(:map)
      marker.image           ||= create :image_asset
    end
  end

  factory :newsitem do
  end

  factory :photo do
  end

  factory :profile, aliases: [ :user_profile ], :class => Ish::UserProfile do
    email { generate(:email) }
    after :build do |doc|
      doc.user ||= create(:user, profile: doc)
    end
  end

  factory :premium_purchase, aliases: [ :purchase ], class: Gameui::PremiumPurchase do
  end

  factory :report do
    name { 'Report Name' }
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
