
FactoryBot.define do

  sequence :email do |n|
    "user-#{n}@company-#{n}.com"
  end

  sequence :message_id do |n|
    "message_id-#{n}"
  end

  sequence :name do |n|
    "name-#{n}"
  end

  sequence :object_key do |n|
    "object_key-#{n}"
  end

  sequence :slug do |n|
    "slug-#{n}"
  end


  ##
  ## factories
  ##

  factory :appliance, class: 'WcoHosting::Appliance' do
    after :build do |doc|
      doc.subscription = create( :subscription, leadset: doc.leadset )
    end
  end

  factory :appliance_tmpl, class: 'WcoHosting::ApplianceTmpl' do
    kind       { WcoHosting::ApplianceTmpl::KIND_HELLOWORLD }
    image      { 'some-image' }
    version    { '0.0.0' }
    volume_zip { 'somefile.zip' }

    factory :hw0_tmpl do
      image      { 'piousbox/php82:0.0.2' }
      volume_zip { 'https://d15g8hc4183yn4.cloudfront.net/wp-content/uploads/2023/11/02121950/helloworld__prototype-1.zip' }
    end

  end

  factory :email_context, class: 'WcoEmail::Context' do
  end

  factory :email_conversation, class: 'WcoEmail::Conversation' do
    subject { 'test-subject-1' }
  end

  factory :email_filter, class: 'WcoEmail::EmailFilter' do
  end

  factory :email_message, class: 'WcoEmail::Message' do
    object_key { generate('object_key') }
    message_id { generate('message_id') }
    after :build do |doc|
      doc.stub = create( :message_stub )
    end
  end

  factory :email_template, class: 'WcoEmail::EmailTemplate' do
    slug { generate('slug') }
  end

  factory :lead, class: 'Wco::Lead' do
    email { generate(:email) }
    after :build do |doc|
      doc.leadset   = Wco::Leadset.where( company_url: doc.email.split('@')[1] ).first
      doc.leadset ||= create(:leadset, email: doc.email)
    end
  end

  factory :leadset, class: 'Wco::Leadset' do
    email { generate(:email) }

    after :build do |doc|
      doc.company_url = doc.email.split('@')[1]
      serverhost   = WcoHosting::Serverhost.all.first
      serverhost ||= create( :serverhost, leadsets: [ doc ] )
      doc.serverhosts = [ serverhost ]
    end
  end

  factory :message_stub, class: 'WcoEmail::MessageStub' do
    object_key { generate('object_key') }
  end

  factory :price, class: 'Wco::Price' do
  end

  factory :product, class: 'Wco::Product' do
    after :build do |doc|
      price = create( :price, product: doc )
    end
  end

  factory :profile, class: 'Wco::Profile' do
    email { email }
    after :build do |doc|
      leadset   = Wco::Leadset.where( email: doc.email ).first
      leadset ||= create( :leadset, email: doc.email )
      doc.leadset = leadset
    end
  end

  factory :serverhost, class: 'WcoHosting::Serverhost' do
    name { generate(:name) }

    factory :vbox1 do
      name { 'vbox1' }
      ssh_host { 'vbox1' }
    end
  end

  factory :subscription, class: 'Wco::Subscription' do
    after :build do |doc|
      doc.product = create( :product )
      doc.price   = doc.product.prices[0]
    end
  end

  factory :tag, class: 'Wco::Tag' do
    slug { generate('slug') }
  end

  factory :task do
    task_template { create(:task_template) }
    user { create(:user) }
  end

  factory :task_template do
    title { 'some title' }
  end

  factory :user do
    email    { generate(:email) }
    password { 'test1234' }
    confirmed_at { Time.now }
    after :build do |doc|
      create( :profile, email: doc.email )
    end
  end

end

