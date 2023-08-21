
require 'net/scp'
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

  ## net-ssh, sshkit
  field :ssh_host
  field :ssh_username
  field :ssh_key
  field :nginx_root, default: '/opt/nginx'

  has_many :appliances, class_name: 'Wco::Appliance'

  # def nginx_add_site rendered_str=nil, config={}
  #   # puts! config, '#nginx_add_site'
  #   File.write( "/usr/local/etc/nginx/sites-available/#{config[:service_name]}", rendered_str )
  #   out = `sudo nginx enable-site #{config[:service_name]} ; \
  #     nginx -s reload ; \
  #     echo ok
  #   `;
  #   puts! out, 'out'
  # end

  def nginx_add_site rendered_str=nil, config={}
    puts! rendered_str, '#nginx_add_site // rendered_str'
    puts! config, '#nginx_add_site // config'

    File.write( "tmp/#{config[:service_name]}", rendered_str )
    Net::SSH.start( ssh_host, ssh_username, keys: ssh_key ) do |ssh|

      out = ssh.scp.upload! "tmp/#{config[:service_name]}", "#{nginx_root}/conf/sites-available/"
      puts! out, 'out'

      out = ssh.exec! "#{nginx_root}/nginx enable-site #{config[:service_name]} ; #{nginx_root}/nginx -s reload"
      puts! out, 'out'

    end

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

# class Instance
#   def chmod
#     start do |ssh|
#       ssh.exec "sudo chmod +x /tmp/provision.sh"
#       # other operations on ssh
#     end
#   end
#   private
#   def start
#     Net::SSH.start(ip, 'ubuntu', keys: "mykey.pem" ) do |ssh|
#       yield ssh
#     end
#   end
# end


## works:
# nginx_root = '/opt/nginx'
# config = { service_name: 'abba', }
# Net::SSH.start( "18.209.12.11", "ubuntu", keys: "access/mac_id_rsa_3.pem" ) do |ssh|
#   out = ssh.scp.upload! "tmp/#{config[:service_name]}", "/opt/tmp/two.txt" do |ch, name, sent, total|
#     puts "#{name}: #{sent}/#{total}"
#   end
#   puts! out, 'out'
# end


