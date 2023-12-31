
class Wco::PhotosController < Wco::ApplicationController

  # @TODO: this is bad? _vp_ 20170513
  skip_authorization_check :only => [ :j_create ]
  protect_from_forgery :except => [ :j_create]

  ## Alphabetized : )

  def destroy
    @photo = Wco::Photo.unscoped.find params[:id]
    authorize! :destroy, @photo
    @photo.gallery.touch if @photo.gallery
    @photo.is_trash = true
    flag = @photo.save
    if flag
      flash[:notice] = "Success"
    else
      flash[:alert] = "No luck: #{@photo.errors.messages}"
    end
    redirect_to request.referrer || root_path
  end

  def index
    authorize! :index, Wco::Photo
    @photos = Wco::Photo.where( user_profile: @current_profile ).page( params[:photos_page] )
  end

  def j_create
    if params[:slug]
      gallery = Wco::Gallery.unscoped.where( :slug => params[:slug] ).first
      gallery ||= Wco::Gallery.unscoped.find params[:slug]
    elsif params[:gallery_id]
      gallery = Wco::Gallery.unscoped.find( params[:gallery_id] )
      gallery ||= Wco::Gallery.unscoped.where( :slug => params[:gallery_id] ).first
    end
    authorize! :create_photo, gallery

    @photo = Wco::Photo.new params[:photo].permit!
    @photo.is_public = true
    @photo.gallery = gallery

    @photo.gallery.touch

    if @photo.save
      j = {
        :name => @photo.photo.original_filename,
        :size => @photo.photo.size,
        :url => @photo.photo.url( :large ),
        :thumbnail_url => @photo.photo.url( :thumb ),
        :delete_url => photo_path(@photo),
        :delete_type => 'DELETE'
      }
      render :json => [ j ]
    else
      render :json => {
        message: @photo.errors.full_messages.join(", "),
        filename: @photo.photo.original_filename,
      }, status: 400
    end
  end

  def new
    authorize! :new, Wco::Photo
    @photo = Wco::Photo.new
  end

  def show
    @photo = Wco::Photo.unscoped.find params[:id]
    authorize! :show, @photo
  end

  def without_gallery
    @photos = Wco::Photo.unscoped.where( :gallery => nil, :is_trash => false )
  end

end

