
class Wco::GalleriesController < Wco::ApplicationController

  before_action :set_lists, only: %i| show |
  before_action :set_gallery, only: %w| destroy edit j_show show update update_ordering |

  # Alphabetized! : )

  def create
    params[:gallery][:tag_ids]&.delete ''

    # params[:gallery][:shared_profiles] ||= []
    # params[:gallery][:shared_profiles].delete('')
    # params[:gallery][:shared_profiles] = Wco::Profile.find params[:gallery][:shared_profiles]

    @gallery = Wco::Gallery.new params[:gallery].permit!
    # @gallery.user_profile = @current_profile
    authorize! :create, @gallery

    if @gallery.save
      # Wco::GalleriesMailer.shared_galleries( params[:gallery][:shared_profiles], @gallery ).deliver
      flash[:notice] = 'Success'
      redirect_to edit_gallery_path(@gallery)
    else
      puts! @gallery.errors.messages
      flash[:alert] = "Cannot create the gallery: #{@gallery.errors.full_messages.join(', ')}"
      render :action => 'new'
    end
  end

  def destroy
    authorize! :destroy, @gallery
    @gallery.delete
    flash[:notice] = 'Marked the gallery deleted.'
    redirect_to( request.referrer || galleries_path )
  end

  def edit
    authorize! :edit, @gallery
  end

  def index
    authorize! :index, Wco::Gallery
    @page_title = 'Galleries'
    @galleries = Wco::Gallery.all.order_by( :created_at => :desc )

    @tags = Wco::Tag.all

    if params[:q]
      q = URI.decode(params[:q])
      @galleries = @galleries.where({ :name => /#{q}/i })
    end

    @galleries = @galleries.page( params[:galleries_page] ).per( current_profile.per_page )
    render '_index'
  end

  def j_show
    authorize! :show, @gallery
    respond_to do |format|
      format.json do
        jjj = {}
        jjj[:photos] = @gallery.photos.map do |ph|
          { :thumbnail_url => ph.photo.url( :thumb ),
          :delete_type => 'DELETE',
          :delete_url => photo_path(ph) }
        end
        render :json => jjj
      end
    end
  end

  def new
    @gallery = Wco::Gallery.new
    @page_title = 'New Gallery'
    authorize! :new, @gallery
  end

  def shared_with_me
    authorize! :index, Wco::Gallery
    @page_title = 'Galleries Shared With Me'
    @galleries = @current_profile.shared_galleries(
      ).order_by( :created_at => :desc
      ).page( params[:shared_galleries_page] ).per( 10 )
    render params[:render_type]
  end

  def show
    authorize! :show, @gallery
    @photos = @gallery.photos.order_by( ordering: :asc )
    @deleted_photos = @gallery.photos.deleted.order_by( ordering: :asc )
  end

  def update_ordering
    authorize! :update, @gallery
    out = []
    params[:gallery][:sorted_photo_ids].each_with_index do |id, idx|
      out.push Photo.find( id ).update_attribute( :ordering, idx )
    end
    flash[:notice] = "Outcomes: #{out}."
    redirect_to action: 'show', id: @gallery.id
  end

  def update
    params[:gallery][:tag_ids]&.delete ''
    authorize! :update, @gallery

    old_shared_profile_ids = @gallery.shared_profiles.map(&:id)
    if params[:gallery][:shared_profiles].present?
      params[:gallery][:shared_profiles].delete('')
    end
    params[:gallery][:shared_profile_ids] = params[:gallery][:shared_profiles]
    params[:gallery].delete :shared_profiles

    flag = @gallery.update_attributes( params[:gallery].permit! )
    if flag
      if params[:gallery][:shared_profile_ids].present?
        new_shared_profiles = Wco::Profile.find( params[:gallery][:shared_profile_ids]
          ).select { |p| !old_shared_profile_ids.include?( p.id ) }
        Wco::GalleriesMailer.shared_galleries( new_shared_profiles, @gallery ).deliver
      end
      flash[:notice] = 'Success.'
      redirect_to edit_gallery_path(@gallery)
    else
      puts! @gallery.errors.messages, 'cannot save gallery'
      flash[:alert] = 'No Luck. ' + @gallery.errors.messages.to_s
      render :action => :edit
    end
  end

  def update_many
    authorize! :update, Wco::Gallery
    galleries = Wco::Gallery.where( :id.in => params[:gallery_ids] )

    tags = Wco::Tag.where( :id.in => params[:tag_ids] )

    if params[:remove]
      galleries.each do |gallery|
        tags.each do |tag|
          gallery.tags.delete tag
        end
        gallery.save
      end
    else
      galleries.each do |gallery|
        gallery.tags.push tags
        gallery.save
      end
    end

    flash_notice 'Unknown outcome, no exception raised.'
    redirect_to request.referrer
  end


  ##
  ## private
  ##
  private

  def set_gallery
    begin
      @gallery = Wco::Gallery.unscoped.find_by :slug => params[:id]
    rescue
      @gallery = Wco::Gallery.unscoped.find params[:id]
    end
    @page_title = "#{@gallery.name} Gallery"
    @page_description = @gallery.subhead
  end

  def set_lists
    @galleries_list = Wco::Gallery.list
  end

end

