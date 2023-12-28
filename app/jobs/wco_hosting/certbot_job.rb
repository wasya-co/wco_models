
require 'net/scp'
require 'open3'
require 'sidekiq'

class WcoHosting::CertbotJob
  include Sidekiq::Job
  sidekiq_options queue: 'wasya_co_rb'

  def perform id
    puts! id, 'CertbotJob#perform...'

    app = WcoHosting::Appliance.find id
    cmd = "ssh #{app.serverhost.ssh_host} 'certbot run -d #{app.host} --nginx -n ' "
    stdout, stderr, status = Open3.capture3(cmd)
    status = status.to_s.split.last.to_i

    if 0 != status && 0 != app.n_retries
      app.update_attributes({ n_retries: app.n_retries - 1 })
      CertbotJob.perform_in( 15.minutes, app.id.to_s )
    end

  end

end
