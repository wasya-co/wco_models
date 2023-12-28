
require 'net/scp'
require 'open3'
require 'droplet_kit'

class WcoHosting::Serverhost
  include Mongoid::Document
  include Mongoid::Timestamps
  # include Mongoid::Autoinc
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
    client = DropletKit::Client.new(access_token: DO_TOKEN_1)
    record = DropletKit::DomainRecord.new(
      type: 'A',
      name: app.subdomain,
      data: app.serverhost.public_ip,
    )
    client.domain_records.create(record, for_domain: app.domain )
  end

  ## obsolete _vp_ 2023-12-23
  def aws_create_subdomain app
    ac   = ActionController::Base.new
    ac.instance_variable_set( :@app, app )
    rendered_str = ac.render_to_string("wco_hosting/scripts/create_subdomain.json")
    # puts '+++ create_subdomain rendered_str:'; print rendered_str

    file = Tempfile.new('prefix')
    file.write rendered_str
    file.close

    cmd = "aws route53 change-resource-record-sets \
      --hosted-zone-id #{ app.route53_zone } \
      --change-batch file://#{ file.path } \
      --profile route53 "
    do_exec( cmd )
  end


  def add_nginx_site app
    ac   = ActionController::Base.new
    ac.instance_variable_set( :@app, app )
    rendered_str = ac.render_to_string("wco_hosting/scripts/nginx_site.conf")
    puts '+++ add_nginx_site rendered_str:'
    print rendered_str

    file = Tempfile.new('prefix')
    file.write rendered_str
    file.close

    cmd = "scp #{file.path} #{ssh_host}:/etc/nginx/sites-available/#{app.service_name}.conf "
    puts! cmd, 'cmd'
    `#{cmd}`

    cmd = "ssh #{ssh_host} 'ln -s /etc/nginx/sites-available/#{app.service_name}.conf /etc/nginx/sites-enabled/#{app.service_name}.conf ' "
    puts! cmd, 'cmd'
    `#{cmd}`

    cmd = "ssh #{ssh_host} 'nginx -s reload ' "
    puts! cmd, 'cmd'
    `#{cmd}`
  end

  def add_docker_service app
    puts! app, '#add_docker_service'

    ac   = ActionController::Base.new
    ac.instance_variable_set( :@app, app )
    ac.instance_variable_set( :@workdir, WORKDIR )
    rendered_str = ac.render_to_string("wco_hosting/docker-compose/dc-#{app.tmpl.kind}")
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

  def create_wordpress_volume app
    ac   = ActionController::Base.new
    ac.instance_variable_set( :@app, app )
    ac.instance_variable_set( :@workdir, WORKDIR )
    rendered_str = ac.render_to_string("wco_hosting/scripts/create_volume")
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
      #{WORKDIR}/wco_hosting/scripts/create_volume ' "
    puts! cmd, 'cmd'
    `#{cmd}`

    puts 'ok #create_volume'
  end

  def create_volume app
    # puts! app.service_name, 'Serverhost#create_volume'

    ac   = ActionController::Base.new
    ac.instance_variable_set( :@app, app )
    ac.instance_variable_set( :@workdir, WORKDIR )
    rendered_str = ac.render_to_string("wco_hosting/scripts/create_volume")
    puts '+++ create_volume rendered_str:'
    print rendered_str

    file = Tempfile.new('prefix')
    file.write rendered_str
    file.close
    # puts! file.path, 'file.path'

    cmd = "scp #{file.path} #{ssh_host}:#{WORKDIR}/scripts/create_volume"
    do_exec( cmd )

    cmd = "ssh #{ssh_host} 'chmod a+x #{WORKDIR}/scripts/create_volume ; #{WORKDIR}/scripts/create_volume ' "
    do_exec( cmd )

    puts 'ok #create_volume'
    return done_exec
  end

  def self.list
    [[nil,nil]] + all.map { |s| [s.name, s.id] }
    # all.map { |s| [s.name, s.id] }
  end

  def do_exec cmd
    # @messages ||= []
    # @errors   ||= []
    # @statuses ||= []

    puts! cmd, '#do_exec'
    stdout, stderr, status = Open3.capture3(cmd)
    status = status.to_s.split.last.to_i
    puts "+++ +++ stdout"
    puts stdout
    # @messages.push( stdout )
    puts "+++ +++ stderr"
    puts stderr
    # @errors.push( stderr )
    puts! status, 'status'
    # @statuses.push( status )
  end

  def done_exec
    @messages ||= []
    @errors   ||= []
    @statuses ||= []
    OpenStruct.new( statuses: @statuses, errors: @errors, messages: @messages )
  end


end