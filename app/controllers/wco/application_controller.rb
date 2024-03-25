
EC   ||= WcoEmail::Conversation
EF   ||= WcoEmail::EmailFilter
EM   ||= WcoEmail::Message
ET   ||= WcoEmail::EmailTemplate
MS   ||= WcoEmail::MessageStub
EMS  ||= MS
OA   ||= Wco::OfficeAction
OAT  ||= Wco::OfficeActionTemplate
OATT ||= Wco::OfficeActionTemplateTie
Sch  ||= WcoEmail::EmailAction

class Wco::ApplicationController < ActionController::Base
  include Wco::ApplicationHelper
  rescue_from Exception, with: :exception_notifier if Rails.env.production?

  check_authorization

  before_action :current_profile
  before_action :set_lists

  def home
    authorize! :home, Wco
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
    ["1", "t", "T", "true"].include?( which )
  end

  def set_lists
  end

end
