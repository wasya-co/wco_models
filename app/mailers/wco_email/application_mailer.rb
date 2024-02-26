
class WcoEmail::ApplicationMailer < ActionMailer::Base

  default from: 'WasyaCo Consulting <no-reply@wco.com.de>'
  helper(Wco::ApplicationHelper)

  layout 'mailer'


  def forwarder_notify msg_id
    @msg = WcoEmail::Message.find msg_id
    mail( to:      "poxlovi@gmail.com",
          subject: "POX::#{@msg.subject}" )
  end

  def shared_galleries profiles, gallery
    return if profiles.count == 0
    @gallery        = gallery
    @domain         = Rails.application.config.action_mailer.default_url_options[:host]
    @galleries_path = IshManager::Engine.routes.url_helpers.galleries_path
    @gallery_path   = IshManager::Engine.routes.url_helpers.gallery_path(@gallery.slug)
    mail( :to => '314658@gmail.com',
          :bcc => profiles.map { |p| p.email },
          :subject => 'You got new shared galleries on pi manager' )
  end

  def option_alert option
    @option = option
    mail({
      :to => option.profile.email,
      :subject => "IshManager Option Alert :: #{option.ticker}",
    })
  end

  def stock_alert watch_id
    @watch = Iro::OptionWatch.find watch_id
    mail({
      to: @watch.profile.email,
      subject: "Iro Watch Alert :: #{@watch.ticker} is #{@watch.direction} #{@watch.mark}."
    })
  end

  def test_email
    mail( to: DEFAULT_RECIPIENT, subject: "Test email at #{Time.now}" )
  end


  def send_context_email ctx_id
    @ctx         = Ctx.find ctx_id
    @renderer    = self.class.renderer ctx: @ctx
    rendered_str = @renderer.render_to_string("/wco_email/email_layouts/_#{@ctx.tmpl.layout}")
    @ctx.update({
      rendered_str: rendered_str,
    })

    mail( from:    @ctx.from_email,
          to:      @ctx.to_email,
          cc:      @ctx.cc,
          bcc:     "poxlovibb1@gmail.com",
          subject: ERB.new( @ctx.subject ).result( @ctx.get_binding ),
          body:    rendered_str,
          content_type: "text/html" )
  end


  def self.renderer ctx:
    out = self.new
    out.instance_variable_set( :@ctx,              ctx )
    out.instance_variable_set( :@lead,             ctx.lead )
    out.instance_variable_set( :@utm_tracking_str, ctx.utm_tracking_str )
    out.instance_variable_set( :@unsubscribe_url,  ctx.unsubscribe_url )
    out.instance_variable_set( :@config,           ctx.config )
    out.instance_variable_set( :@renderer,         out )
    return out
  end

end
