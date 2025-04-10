
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

  field :do_id, type: :string

  has_many :appliances, class_name: 'WcoHosting::Appliance'
  has_many :files,      class_name: 'WcoHosting::File'

  def self.do_list_keys
    out = HTTParty.get( "https://api.digitalocean.com/v2/account/keys",
      headers: { 'Authorization' => "Bearer #{DO_READER_TOKEN}" },
      :debug_output => $stdout,
    );
  end

  def self.list
    [[nil,nil]] + all.map { |s| [s.name, s.id] }
    # all.map { |s| [s.name, s.id] }
  end

  def add_docker_service app
    @obj = app
    cmd =<<~AOL
      cd /Users/piousbox/projects/ansible
      . zenv/bin/activate
      ansible-playbook -i inventory/do.yml --limit #{self.name} playbooks/hosted-packagedapp.yml --extra-vars '{"appliance_slug": "#{app.slug}", "codebase_zip": "#{app.tmpl.volume_zip_url}", "next_port": "#{self.next_port}"}'
    AOL
    do_exec cmd
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

=begin
  def create_appliance app
    # puts! app, 'Serverhost#create_appliance'
    create_subdomain(   app )
    create_volume(      app )
    add_docker_service( app )
    add_nginx_site(     app )
    # load_database( app )
  end
=end

  def create_subdomain app
    @obj = app
    Wco::Log.puts! @obj, 'Creating subdomain...', obj: @obj
    client = DropletKit::Client.new(access_token: DO_TOKEN_1)
    record = DropletKit::DomainRecord.new(
      type: 'A',
      name: app.subdomain,
      data: app.serverhost.public_ip,
    )
    client.domain_records.create(record, for_domain: app.domain )
    Wco::Log.puts! record, 'Created subdomain.', obj: @obj
    # WcoHosting::Subdomain.create!( domain: app.domain, name: app.subdomain )
  end

  def do_create_server!
    out = HTTParty.post( "https://api.digitalocean.com/v2/droplets", body: {
        name: name,
        size: "s-1vcpu-2gb",
        region: "sfo2",
        image: "ubuntu-22-04-x64",
        ssh_keys: [ 40460634 ], # 2np, "71:9a:7e:9a:54:55:af:d0:16:47:5c:57:a8:c3:f0:2b"
        vpc_uuid: "b9f748b6-4649-4506-a457-b70d2b57b313",
      }.to_json,
      headers: { 'Content-Type'  => 'application/json',
                 'Authorization' => "Bearer #{DO_DROPLET_TOKEN}" },
      :debug_output => $stdout,
    );
    puts! out, '#create_do_server()'
    out = out.parsed_response
    self.do_id = out['droplet']['id']
    self.save

    do_project_id = '4dad5c55-1a11-4c2b-9e14-1cd69513d940' # WcoHosting DO project id
    out = HTTParty.post( "https://api.digitalocean.com/v2/projects/#{do_project_id}/resources", body: {
        resources: [ "do:droplet:#{out['droplet']['id']}" ],
      }.to_json,
      headers: { 'Content-Type'  => 'application/json',
                 'Authorization' => "Bearer #{DO_DROPLET_TOKEN}" },
      :debug_output => $stdout,
    );
    puts! out, 'assign droplet to a project'
  end

  def do_exec cmd
    Wco::Log.puts! cmd, '#do_exec', obj: @obj
    IO.popen(cmd).each do |line|
      Wco::Log.puts line, obj: @obj
    end
  end

  def to_s
    "<Serverhost name=#{name} next_port=#{next_port} ssh_host=#{ssh_host} />"
  end

end