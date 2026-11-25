
##
## this doesn't work and was never tested or used.
## 2026-11-14
##
class Wco::PublisherD10 < Wco::Publisher

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
