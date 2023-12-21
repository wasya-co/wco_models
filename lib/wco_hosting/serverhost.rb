
require 'net/scp'

class WcoHosting::Serverhost
  include Mongoid::Document
  include Mongoid::Timestamps
  # include Mongoid::Autoinc
  store_in collection: 'wco_serverhosts'

  field     :name, type: :string
  validates :name, uniqueness: { scope: :leadset }, presence: true

  belongs_to :leadset, class_name: 'Wco::Leadset'

  field :next_port, type: :integer, default: 8000

  field :nginx_root, default: '/opt/nginx'
  field :public_ip

  ## net-ssh, sshkit
  field :ssh_host
  # field :ssh_username
  # field :ssh_key

  has_many :appliances, class_name: 'WcoHosting::Appliance'

  def add_nginx_site app
    ac   = ActionController::Base.new
    ac.instance_variable_set( :@app, app )
    rendered_str = ac.render_to_string("scripts/nginx_site.conf")
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

    cmd = "ssh #{ssh_host} 'certbot run -d #{app.origin} --nginx -n ' "
    puts! cmd, 'cmd'
    `#{cmd}`

  end

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

  def create_wordpress_volume app
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

  def create_volume app
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

  def self.list
    [[nil,nil]] + all.map { |s| [s.name, s.id] }
    # all.map { |s| [s.name, s.id] }
  end

end