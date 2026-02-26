
class Wco::ProfilesController < Wco::ApplicationController

  def create
    @profile = Wco::Profile.new params[:profile].permit!
    authorize! :create, @profile
    if @profile.save
      flash_notice @profile
      redirect_to action: :index
    else
      flash_alert @profile
      render action: 'new'
    end
  end

  def edit
    @profile = Wco::Profile.find params[:id]
    authorize! :update, @profile
  end

  def index
    @profiles = Wco::Profile.all
    authorize! :index, Wco::Profile
    if params[:q]
      q = URI.decode(params[:q])
      @profiles = @profiles.where({ email: /#{q}/i })

      if params[:q] == 'pi'
        profile = Wco::Profile.find_by email: 'piousbox@gmail.com'
        redirect_to action: 'edit', id: profile.id.to_s
        return
      end
    end
  end

  def new
    @new_profile = Wco::Profile.new
    authorize! :new, @new_profile
  end

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
