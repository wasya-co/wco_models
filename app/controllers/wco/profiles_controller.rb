
class Wco::ProfilesController < Wco::ApplicationController

  def update
    @profile = Wco::Profile.find params[:id]
    authorize! :update, @profile

    # if params[:photo]
    #   photo = Photo.new :photo => params[:photo]
    #   @profile.profile_photo = photo
    # end

    flag = @profile.update params[:profile].permit!
    if flag
      flash_notice "Updated profile #{@profile.email}"
    else
      flash_alert "Cannot update profile: #{@profile.errors.full_messages}"
    end
    if params[:redirect_to]
      redirect_to params[:redirect_to]
    else
      redirect_to request.referrer
    end
  end

end
