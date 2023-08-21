
# require 'autoinc'

class Wco::Serverhost
  include Mongoid::Document
  include Mongoid::Timestamps
  # include Mongoid::Autoinc

  field :name, type: :string
  validates :name, uniqueness: { scope: :leadset_id }, presence: true

  field :next_port, type: :integer, default: 8000
  # increments :next_port

  field :leadset_id, type: :integer

  has_many :appliances, class_name: 'Wco::Appliance'

  def nginx_add_site rendered_str=nil, config={}
    # puts! config, '#nginx_add_site'
    File.write( "/usr/local/etc/nginx/sites-available/#{config[:service_name]}", rendered_str )
    out = `sudo nginx enable-site #{config[:service_name]} ; \
      nginx -s reload ; \
      echo ok
    `;
    puts! out, 'out'
  end

  def docker_add_service rendered_str=nil, config={}
    # puts! config, '#docker_add_service'
    File.write( "/Users/piousbox/projects/docker_demo/dc-#{config[:service_name]}.yml", rendered_str )
    out = ` mkdir /Users/piousbox/projects/docker_demo/#{config[:service_name]}_data `
    puts! out, 'out'
    out = ` cd /Users/piousbox/projects/docker_demo/ ; \
      docker compose -f dc-#{config[:service_name]}.yml up -d #{config[:service_name]} ; \
      echo ok
    `;
    puts! out, 'out'
  end

  def load_data rendered_str=nil, config={}
    File.write( "/Users/piousbox/projects/docker_demo/#{config[:service_name]}_data/index.html", rendered_str )
  end


end
