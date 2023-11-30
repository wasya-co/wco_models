
require 'net/scp'

class Wco::Serverhost
  include Mongoid::Document
  include Mongoid::Timestamps
  # include Mongoid::Autoinc

  field :name, type: :string
  # validates :name, uniqueness: { scope: :leadset_id }, presence: true
  validates :name, uniqueness: { scope: :wco_leadset }, presence: true

  # field :leadset_id, type: :integer
  # has_and_belongs_to_many :leadsets, class_name: 'Wco::Leadset', inverse_of: :serverhosts
  belongs_to :wco_leadset, class_name: 'Wco::Leadset'

  field :next_port, type: :integer, default: 8000

  field :nginx_root, default: '/opt/nginx'
  field :public_ip

  ## net-ssh, sshkit
  field :ssh_host
  # field :ssh_username
  # field :ssh_key

  has_many :appliances, class_name: 'Wco::Appliance'

  # def nginx_add_site rendered_str=nil, config={}
  #   puts! rendered_str, '#nginx_add_site // rendered_str'
  #   puts! config, '#nginx_add_site // config'
  #   File.write( "tmp/#{config[:service_name]}", rendered_str )
  #   Net::SSH.start( ssh_host, ssh_username, keys: ssh_key ) do |ssh|
  #     out = ssh.scp.upload! "tmp/#{config[:service_name]}", "#{nginx_root}/conf/sites-available/"
  #     puts! out, 'out'
  #     out = ssh.exec! "#{nginx_root}/nginx enable-site #{config[:service_name]} ; #{nginx_root}/nginx -s reload"
  #     puts! out, 'out'
  #   end
  # end

  WORKDIR = "/opt/projects/docker"

  def add_docker_service app
    puts! app, '#add_docker_service'

    ac   = ActionController::Base.new
    ac.instance_variable_set( :@app, app )
    ac.instance_variable_set( :@workdir, WORKDIR )
    rendered_str = ac.render_to_string("docker-compose/dc-#{app.kind}")
    puts '+++ add_docker_service rendered_str:'
    print rendered_str

    file = Tempfile.new('prefix')
    file.write rendered_str
    file.close
    puts! file.path, 'file.path'

    cmd = "scp #{file.path} #{ssh_host}:#{WORKDIR}/dc-#{app.service_name}.yml "
    puts! cmd, 'cmd'
    `#{cmd}`

    cmd = "ssh #{ssh_host} 'cd #{WORKDIR} ; \
      docker compose -f dc-#{app.service_name}.yml up -d #{app.service_name} ; \
      echo ok #add_docker_service ' "
    puts! cmd, 'cmd'
    `#{cmd}`

    puts "ok '#add_docker_service'"
  end

  def create_volume app={}
    puts! app, '#create_volume'

    ac   = ActionController::Base.new
    ac.instance_variable_set( :@app, app )
    ac.instance_variable_set( :@workdir, WORKDIR )
    rendered_str = ac.render_to_string("scripts/create_volume")
    # puts '+++ create_volume rendered_str:'
    # print rendered_str

    file = Tempfile.new('prefix')
    file.write rendered_str
    file.close
    # puts! file.path, 'file.path'

    cmd = "scp #{file.path} #{ssh_host}:#{WORKDIR}/scripts/create_volume"
    puts! cmd, 'cmd'
    `#{cmd}`

    cmd = "ssh #{ssh_host} 'chmod a+x #{WORKDIR}/scripts/create_volume ; \
      #{WORKDIR}/scripts/create_volume ' "
    puts! cmd, 'cmd'
    `#{cmd}`

    puts 'ok #create_volume'
  end


end

