
require 'net/scp'
require 'open3'
require 'droplet_kit'

class WcoHosting::Serverhost
  include Mongoid::Document
  include Mongoid::Timestamps
  # include Mongoid::Autoinc
  include Mongoid::Paranoia
  store_in collection: 'wco_serverhosts'

  WORKDIR = "/opt/projects/docker"

  field     :name, type: :string
  validates :name, uniqueness: { scope: :leadset }, presence: true

  has_and_belongs_to_many :leadsets, class_name: 'Wco::Leadset'

  field :next_port, type: :integer, default: 8000

  field :nginx_root, default: '/opt/nginx'
  field :public_ip

  ## net-ssh, sshkit
  field :ssh_host
  # field :ssh_username
  # field :ssh_key

  has_many :appliances, class_name: 'WcoHosting::Appliance'

  def create_appliance app
    # puts! app, 'Serverhost#create_appliance'

    create_subdomain(   app )
    create_volume(      app )
    add_docker_service( app )
    add_nginx_site(     app )
    # load_database( app )

    update({ next_port: app.serverhost.next_port + 1 })
  end

  def create_subdomain app
    @obj = app
    Wco::Log.puts! @obj, '#create_subdomain...', obj: @obj

    client = DropletKit::Client.new(access_token: DO_TOKEN_1)
    record = DropletKit::DomainRecord.new(
      type: 'A',
      name: app.subdomain,
      data: app.serverhost.public_ip,
    )
    client.domain_records.create(record, for_domain: app.domain )

    Wco::Log.puts! record, 'created subdomain?', obj: @obj
  end

  def add_nginx_site app
    @obj = app

    ac   = ActionController::Base.new
    ac.instance_variable_set( :@app, app )
    rendered_str = ac.render_to_string("wco_hosting/scripts/nginx_site.conf")
    Wco::Log.puts! rendered_str, 'add_nginx_site rendered_str', obj: @obj

    file = Tempfile.new('prefix')
    file.write rendered_str
    file.close

    cmd = "scp #{file.path} #{ssh_host}:/etc/nginx/sites-available/#{app.service_name}.conf "
    do_exec cmd

    cmd = "ssh #{ssh_host} 'ln -s /etc/nginx/sites-available/#{app.service_name}.conf /etc/nginx/sites-enabled/#{app.service_name}.conf ' "
    do_exec cmd

    cmd = "ssh #{ssh_host} 'nginx -s reload ' "
    do_exec cmd
  end

  def add_docker_service app
    @obj = app
    Wco::Log.puts! nil, '#add_docker_service', obj: @obj

    ac   = ActionController::Base.new
    ac.instance_variable_set( :@app, app )
    ac.instance_variable_set( :@workdir, WORKDIR )
    rendered_str = ac.render_to_string("wco_hosting/docker-compose/dc-#{app.tmpl.kind}")
    Wco::Log.puts! rendered_str, 'add_docker_service rendered_str', obj: @obj

    file = Tempfile.new('prefix')
    file.write rendered_str
    file.close
    # puts! file.path, 'file.path'

    cmd = "scp #{file.path} #{ssh_host}:#{WORKDIR}/dc-#{app.service_name}.yml "
    do_exec cmd

    cmd = "ssh #{ssh_host} 'cd #{WORKDIR} ; \
      docker compose -f dc-#{app.service_name}.yml up -d #{app.service_name} ; \
      echo ok #add_docker_service ' "
    do_exec cmd
  end

  def create_wordpress_volume app
    @obj = app

    ac   = ActionController::Base.new
    ac.instance_variable_set( :@app, app )
    ac.instance_variable_set( :@workdir, WORKDIR )
    rendered_str = ac.render_to_string("wco_hosting/scripts/create_volume")
    Wco::Log.puts! rendered_str, 'create_volume rendered_str', obj: @obj

    file = Tempfile.new('prefix')
    file.write rendered_str
    file.close
    # puts! file.path, 'file.path'

    cmd = "scp #{file.path} #{ssh_host}:#{WORKDIR}/scripts/create_volume"
    do_exec cmd

    cmd = "ssh #{ssh_host} 'chmod a+x #{WORKDIR}/scripts/create_volume ; \
      #{WORKDIR}/wco_hosting/scripts/create_volume ' "
    do_exec cmd
  end

  def create_volume app
    @obj = app
    Wco::Log.puts! app.service_name, 'Serverhost#create_volume', obj: @obj

    ac   = ActionController::Base.new
    ac.instance_variable_set( :@app, app )
    ac.instance_variable_set( :@workdir, WORKDIR )
    rendered_str = ac.render_to_string("wco_hosting/scripts/create_volume")
    Wco::Log.puts! rendered_str, 'create_volume rendered_str', obj: @obj

    file = Tempfile.new('prefix')
    file.write rendered_str
    file.close
    # puts! file.path, 'file.path'

    cmd = "scp #{file.path} #{ssh_host}:#{WORKDIR}/scripts/create_volume"
    do_exec( cmd )

    cmd = "ssh #{ssh_host} 'chmod a+x #{WORKDIR}/scripts/create_volume ; #{WORKDIR}/scripts/create_volume ' "
    do_exec( cmd )
  end

  def do_exec cmd
    Wco::Log.puts! cmd, '#do_exec', obj: @obj

    stdout, stderr, status = Open3.capture3(cmd)
    status = status.to_s.split.last.to_i
    Wco::Log.puts! stdout, 'stdout', obj: @obj
    Wco::Log.puts! stderr, 'stderr', obj: @obj
    Wco::Log.puts! status, 'status', obj: @obj
  end

  def self.list
    [[nil,nil]] + all.map { |s| [s.name, s.id] }
    # all.map { |s| [s.name, s.id] }
  end
end