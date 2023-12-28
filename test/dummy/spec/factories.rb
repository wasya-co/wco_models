
FactoryBot.define do

  sequence :email do |n|
    "user-#{n}@company-#{n}.com"
  end

  sequence :name do |n|
    "name-#{n}"
  end

  ##
  ## factories
  ##

  factory :appliance, class: 'WcoHosting::Appliance' do
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

  factory :leadset, class: 'Wco::Leadset' do
    email { generate(:email) }

    after :build do |doc|
      doc.company_url = doc.email.split('@')[1]
      serverhost   = WcoHosting::Serverhost.all.first
      serverhost ||= create( :serverhost, leadset: doc )
      doc.serverhosts = [ serverhost ]
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
