
class Wco::ApplicationController < ActionController::Base
  include Wco::ApplicationHelper

  check_authorization

  before_action :current_profile

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

end
