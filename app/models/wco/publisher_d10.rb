
##
## 2026-11-14
##
module Wco::PublisherD10

  def field_tags_data
    publisher = self

    tags = publisher.tags.where( site: publisher.site )
    return "" if !tags.present?

    out = tags.map do |tag|
      { "type": "taxonomy_term--tags", "id": tag.external_id.to_s }
    end

    out =<<~AOL
    "field_tags": { "data": <%= out %> }
AOL
    out.to_json
  end

  def field_image_thumb_data photo=nil
    return '' if !photo

    out =<<~AOL
    "field_image_thumb": { "data": { "type": "file--file", "id": "#{save_image(photo)}" } },
AOL
    out.to_json
  end

  ## this works, if file_entity is not present in d10.
  def save_image image
    publisher = self
    # image = Wco::Photo.all.last

    site = publisher.site
    image_url = image.photo.url(:thumb)

    uri = URI(image_url)
    image_data = Net::HTTP.get(uri)
    credentials = Base64.strict_encode64("#{site.username}:#{site.password}")

    puts! 'Saving an image...'
    response = HTTParty.post(
      "#{site.origin}/jsonapi/node/article/field_image_thumb",
      headers: {
        'Content-Type' => 'application/octet-stream',
        'Accept' => 'application/vnd.api+json',
        'Content-Disposition' => 'file; filename="thumbnail.jpg"',
        'Authorization' => "Basic #{credentials}",
      },
      body: image_data
    )
    puts! response, 'response'
    field_image_thumb_id = response['data']['id']
  end

  ## this doesn't work and was never tested or used.
  def self.context_eval

    @headers['Content-Type']  = 'application/vnd.api+json'
    @headers['Authorization'] = "Basic base64(#{@site.username}:#{@site.password})"

    @report                  = Wco::Report.find @props[:report_id]

    tags = @publisher.tags.where( site: @site )
    @tags_data = tags.map do |tag|
      { "type": "taxonomy_term--tags", "id": tag.external_id.to_s }
    end.to_json
    puts! @tags_data, '@tags_data'

    @field_image_thumb_data = ""
    if false || @report.image_thumb
      image_url ||= @report.image_thumb.photo.url(:thumb)

    uri = URI(image_url)
    image_data = Net::HTTP.get(uri)
    credentials = Base64.strict_encode64("#{@site.username}:#{@site.password}")

      puts! 'Saving an image...'
    response = HTTParty.post(
      "#{@site.origin}/jsonapi/node/article/field_image_thumb",
      headers: {
        'Content-Type' => 'application/octet-stream',
        'Accept' => 'application/vnd.api+json',
        'Content-Disposition' => 'file; filename="thumbnail.jpg"',
        'Authorization' => "Basic #{credentials}",
      },
      body: image_data
    )
      puts! response, 'response'
      field_image_thumb_id = response['data']['id']
      @field_image_thumb_data =<<~AOL
        "field_image_thumb": { "data": { "type": "file--file", "id": "#{field_image_thumb_id}" } },
    AOL
      puts! @field_image_thumb_data, '@field_image_thumb_data'
    end

  end

end
