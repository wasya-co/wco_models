
class Wco::ReportsController < Wco::ApplicationController

  before_action :set_lists

  def create
    params[:report][:tag_ids]&.delete ''

    @report = Wco::Report.new params[:report].permit!
    authorize! :create, @report

    @report.author = current_profile

    if params[:report][:image_thumb]&.[](:image).present?
      thumb = @report.image_thumb || @report.build_image_thumb
      thumb.image = params[:report][:image_thumb_attributes][:image]
      thumb.save
    end

    if @report.save
      flash_notice "created report"
    else
      flash_alert "Cannot create report: #{@report.errors.messages}"
    end
    redirect_to action: 'index'
  end

  def destroy
    @report = Wco::Report.find params[:id]
    authorize! :destroy, @report
    if @report.destroy
      flash_notice 'ok'
    else
      flash_alert 'No luck.'
    end
    redirect_to action: 'index'
  end

  def edit
    @report = Wco::Report.unscoped.find params[:id]
    authorize! :edit, @report
  end

  def index
    authorize! :index, Wco::Report
    @reports = Wco::Report.all
    @reports = @reports.page( params[:reports_page] ).per( current_profile.per_page )
  end

  def new
    authorize! :new, Wco::Report
    @new_report = Wco::Report.new
  end

  def show
    @report = Wco::Report.unscoped.find params[:id]
    authorize! :show, @report

    @publishers_list = Wco::Publisher.list

    # @config = JSON.parse( @report.config_json )
    # @duration_ms = @config['vtimes'].last.to_i + @config['vdurations'].last.to_i
  end

  ## not working, no access
  def to_company_linkedin
    @report = Wco::Report.unscoped.find params[:id]
    authorize! :edit, @report
    pi = Wco::Profile.pi

    response = HTTParty.get(
      "https://api.linkedin.com/v2/organizationAcls?q=roleAssignee",
      headers: {
        "Authorization" => "Bearer #{pi.linkedin_access_token}"
      }
    )
    org = JSON.parse(response.body)
    puts! org, 'org'

    uri = URI("https://api.linkedin.com/v2/ugcPosts")

    req = Net::HTTP::Post.new(uri)
    req["Authorization"] = "Bearer #{pi.linkedin_access_token}"
    req["Content-Type"] = "application/json"
    req["X-Restli-Protocol-Version"] = "2.0.0"

    body = {
      author: "urn:li:organization:#{org['id']}",
      lifecycleState: "PUBLISHED",
      specificContent: {
        "com.linkedin.ugc.ShareContent": {
          shareCommentary: {
            text: "#{@report.title}   #{@report.body}",
          },
          shareMediaCategory: "NONE"
        }
      },
      visibility: {
        "com.linkedin.ugc.MemberNetworkVisibility": "PUBLIC"
      }
    }

    req.body = body.to_json

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end

    puts res.body
  end

  def to_facebook
    @report = Wco::Report.unscoped.find params[:id]
    authorize! :edit, @report
    pi = Wco::Profile.pi

    text = @report.body
    text.gsub!(%r{</p\s*>}i, "\n")
    text.gsub!(%r{<p\s*/?>}i, "")
    text.gsub!(%r{<[^>]*>}, "")
    text.strip.gsub(/\n{3,}/, "\n\n")

    Wco::FacebookPoster.new.post("#{@report.title}\n\n#{text}")
    flash_notice 'Probably ok.'
    redirect_to request.referrer
  end

  def to_linkedin
    @report = Wco::Report.unscoped.find params[:id]
    authorize! :edit, @report
    pi = Wco::Profile.pi

    uri = URI("https://api.linkedin.com/v2/userinfo")
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "Bearer #{pi.linkedin_access_token}"

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
    profile = JSON.parse(res.body)
    puts! profile, 'profile'
    user_id = profile['sub']

    # Create post
    post_uri = URI("https://api.linkedin.com/v2/ugcPosts")
    post_req = Net::HTTP::Post.new(post_uri)

    post_req['Authorization'] = "Bearer #{pi.linkedin_access_token}"
    post_req['Content-Type'] = "application/json"
    post_req['X-Restli-Protocol-Version'] = "2.0.0"


    text = @report.body
    text.gsub!(%r{</p\s*>}i, "\n")
    text.gsub!(%r{<p\s*/?>}i, "")
    text.gsub!(%r{<[^>]*>}, "")
    text.strip.gsub(/\n{3,}/, "\n\n")

    body = {
      author: "urn:li:person:#{user_id}",
      lifecycleState: "PUBLISHED",
      specificContent: {
        "com.linkedin.ugc.ShareContent": {
          shareCommentary: {
            text: "#{@report.title}\n\n#{text}",
          },
          shareMediaCategory: "NONE"
        }
      },
      visibility: {
        "com.linkedin.ugc.MemberNetworkVisibility": "PUBLIC"
      }
    }

    post_req.body = body.to_json

    post_res = Net::HTTP.start(post_uri.hostname, post_uri.port, use_ssl: true) do |http|
      http.request(post_req)
    end

    render json: JSON.parse(post_res.body)
  end


  def update
    params[:report][:tag_ids]&.delete ''
    img_thumb_params = params[:report][:image_thumb]
    params[:report].delete :image_thumb
    # puts! img_thumb_params, 'img_thumb_params'

    @report = Wco::Report.unscoped.find params[:id]
    authorize! :update, @report

    if @report.update params[:report].permit!

      if img_thumb_params.present?
        @photo = Wco::Photo.new photo: img_thumb_params
        @photo.save!
        @report.image_thumb = @photo
      end


      flash_notice "updated report"
    else
      flash_alert "Cannot update report: #{@report.errors.messages}"
    end
    redirect_to action: 'index'
  end

  ##
  ## private
  ##
  private

  def set_lists
    @tags_list = Wco::Tag.list
    @newsvideos_list = Wco::Newsvideo.list
  end

end
