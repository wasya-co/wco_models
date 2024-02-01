
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

  ## A

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

  ## E

  factory :email_action_template, class: 'WcoEmail::EmailActionTemplate' do
    after :build do |doc|
      doc.email_template = ET.all.first || create( :email_template )
    end
  end

  factory :email_context, class: 'WcoEmail::Context' do
    subject { 'xx test-subject xx' }
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

  ## G

  factory :gallery, class: 'Wco::Gallery' do
    name { generate('name') }
    slug { generate('slug') }
  end

  ## I

  factory :invoice, class: 'Wco::Invoice' do
  end

  ## L

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

  ## M

  factory :message_stub, class: 'WcoEmail::MessageStub' do
    object_key { generate('object_key') }
    config { { process_images: false }.to_json }
  end

  ## P

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

  factory :publisher, class: 'Wco::Publisher' do
    slug { generate(:slug) }

    factory :publisher_pi_drup_prod_report do
      context_eval { <<~AOL
        @headers['Content-Type'] = 'application/hal+json'
        @report                  = Wco::Report.find @props[:report_id]
        AOL
      }
      post_path { '/node?_format=hal_json' }
      post_body_tmpl { <<~AOL
        {
          "_links": {
            "type":{"href":"<%= @site.origin %>/rest/type/node/article"}
          },
          "title":[{"value":"Test Au <%= @report.title.gsub('"', '\"')     %>" }],
          "body":[{"value": "<%= @report.body.gsub('"', '\"')      %>" }],
          "type":[{"target_id":"article"}]
        }
        AOL
      }
      slug { 'publish2-pi_drup_prod-report' }

      after :build do |doc|
        pi_local = Wco::Site.where( origin: 'https://piousbox.com' ).first
        pi_local ||= create( :pi_drup_prod )
        doc.site = pi_local
      end
    end

  end

  ## R

  factory :report, class: 'Wco::Report' do
    title { generate(:name) }
    body { "xx some-body xx" }
  end

  ## S

  factory :serverhost, class: 'WcoHosting::Serverhost' do
    name { generate(:name) }

    factory :vbox1 do
      name     { 'vbox1' }
      ssh_host { 'vbox1' }
    end
  end

  factory :site, class: 'Wco::Site' do
    slug { generate(:slug) }

    factory :pi_drup_prod do
      origin   { 'https://piousbox.com' }
      slug     { 'pi-drup-prod' }
      username { PI_DRUP_PROD_USERNAME }
      password { PI_DRUP_PROD_PASSWD }
    end
  end

  factory :subscription, class: 'Wco::Subscription' do
    after :build do |doc|
      doc.product = create( :product )
      doc.price   = doc.product.prices[0]
    end
  end

  ## T

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

  ## U

  factory :unsubscribe, class: 'WcoEmail::Unsubscribe' do
  end

  factory :user do
    email    { generate(:email) }
    password { 'test1234' }
    confirmed_at { Time.now }
    after :build do |doc|
      create( :profile, email: doc.email )
    end
  end

  ## V

  factory :video, class: 'Wco::Video' do
    name { generate(:name) }
  end

end

