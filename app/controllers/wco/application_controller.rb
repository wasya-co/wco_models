
require_relative '../../../lib/shortcuts'
# EC   ||= WcoEmail::Conversation
# EF   ||= WcoEmail::EmailFilter
# EM   ||= WcoEmail::Message
# ET   ||= WcoEmail::EmailTemplate
# MS   ||= WcoEmail::MessageStub
# EMS  ||= MS
# OA   ||= Wco::OfficeAction
# OAT  ||= Wco::OfficeActionTemplate
# OATT ||= Wco::OfficeActionTemplateTie
# Sch  ||= WcoEmail::EmailAction

class Wco::ApplicationController < ActionController::Base
  include Wco::ApplicationHelper
  # rescue_from Exception, with: :exception_notifier if Rails.env.production?

  check_authorization

  before_action :current_profile
  before_action :set_lists

  def error
    raise "test exception notifier"
    out = 5 / 0
  end

  def grapesjs
  end

  def home
    authorize! :home, Wco
  end


  def linkedin_cb
    authorize! :open_permission, Wco
    code = params[:code]
    pi = Wco::Profile.pi

    uri = URI("https://www.linkedin.com/oauth/v2/accessToken")
    res = Net::HTTP.post_form(uri, {
      grant_type: 'authorization_code',
      code: code,
      redirect_uri: linkedin_cb_url,
      client_id: pi.linkedin_client_id,
      client_secret: pi.linkedin_client_secret,
    })
    data = JSON.parse(res.body)
    pi.update({ linkedin_access_token: data['access_token'] })
    flash[:notice] = 'Ok.'
    redirect_to '/'
  end

  def linkedin_sync
    authorize! :open_permission, Wco

    pi = Wco::Profile.pi
    redirect_uri = linkedin_cb_url

    base_url = "https://www.linkedin.com/oauth/v2/authorization"

    params = {
      response_type: "code",
      client_id: pi.linkedin_client_id,
      redirect_uri: redirect_uri,

      scope: "openid profile email w_member_social"  ## r_organization_admin w_organization_social
    }

    url = "#{base_url}?#{URI.encode_www_form(params)}"

    puts! url, "linkedin_oauth_url"

    redirect_to url, allow_other_host: true
  end

  def settings
    authorize! :home, Wco
    @settings = {}
    Wco::Setting.all.to_a.map do |item|
      @settings[item.key] = item.value
    end
  end

  def set_settings
    authorize! :home, Wco
    params.fetch(:settings, {}).each do |key, value|
      next unless Wco::Setting::KEYS.include?(key)

      setting = Wco::Setting.find_or_initialize_by(key: key)
      setting.value = value.strip
      setting.save!
    end

    redirect_to settings_path, notice: 'Settings updated.'
  end

  def tinymce
    authorize! :home, Wco
    render layout: false
  end


  ##
  ## private
  ##
  private

  # def current_ability
  #   @current_ability ||= Ability.new(current_user)
  # end

  def current_profile
    @current_profile ||= Wco::Profile.find_by( email: current_user.email )
  end

  def current_leadset
    @current_leadset ||= current_profile.leadset
  end

  def exception_notifier(exc)
    puts! exc, "wco_models custom Exception"
    ::ExceptionNotifier.notify_exception(
      exc,
      data: {
        backtrace: exc.backtrace,
      }
    )
    raise exc
  end

  def flash_alert what
    flash[:alert] ||= []
    if String == what.class
      str = what
    else
      str = "Cannot create/update #{what.class.name}: #{what.errors.full_messages.join(', ')} ."
    end
    flash[:alert] << str
  end

  def flash_notice what
    flash[:notice] ||= []
    if String == what.class
      str = what
    else
      str = "Created/updated #{what.class.name} ."
    end
    flash[:notice] << str
  end

  def my_truthy? which
    ["1", "t", "true"].include?( which.downcase )
  end

  def set_lists
    @new_tag      = Wco::Tag.new
    @sidebar_tags = @current_profile.sidebar_tags
    @tags         = Wco::Tag.all.order_by( slug: :asc )
    @tags_list    = Wco::Tag.list
  end

end
