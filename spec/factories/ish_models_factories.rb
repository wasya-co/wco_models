
FactoryBot.define do

  # alphabetized : )

  sequence :email do |n|
    "test-#{n}@email.com"
  end
  sequence :handle do |n|
    "handle-#{n}"
  end
  sequence :message_id do |n|
    "message-id-#{n}"
  end
  sequence :name do |n|
    "name-#{n}"
  end
  sequence :slug do |n|
    "slug-#{n}"
  end
  sequence :youtube_id do |n|
    "youtube_id-#{n}"
  end

  factory :email_action, class: ::Office::EmailAction do
    slug { generate(:slug) }
    email_template { create( 'email_template' ) }
  end

  factory :email_campaign, class: ::Ish::EmailCampaign do
    subject { 'xxSome Subjectxx' }
    from_email { 'from@email.com' }
  end

  factory :email_context, class: ::Ish::EmailContext do
  end

  factory :email_conversation, class: ::Office::EmailConversation do
    latest_at { Time.now }
    after :create do |convo|
      create( :email_message, email_conversation: convo )
    end
  end

  factory :email_message, class: Office::EmailMessage do
    message_id { generate(:message_id) }
    subject { "Some Subject" }
  end

  factory :email_template, class: ::Ish::EmailTemplate do
    slug { generate(:slug) }
    subject { 'xxSome Subjectxx' }
    body { 'Email Template Body' }
  end

  factory :gallery do
    name { generate(:slug) }
    slug { generate(:slug) }
    is_trash { false }
    is_public { true }
    after :build do |g|
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
      ## I need both: location_id and map.image ?! _vp_ 2022-09-17
      map.image = create(:image_asset, location_id: map.id)
    end
  end

  factory :marker, class: Gameui::Marker do
    name { generate(:name) }
    item_type { ::Gameui::Marker::ITEM_TYPES[0] }
    after :build do |marker|
      marker.creator_profile ||= create(:profile)
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
  end

  factory :purchase, class: 'Ish::Payment' do
  end

  factory :report do
    name { 'Report Name' }
  end

  factory :user do
    email { generate(:email) }
    password { '1234567890' }
  end

  factory :video do
    name { 'some-name' }
  end


end
