
json.id @newsvideo.id.to_s
json.generate_url api_newsvideo_generate_url(@newsvideo, { api_key:    Wco::Setting.get('WASYACO_SIMPLE_API_KEY'),
                                                           api_secret: Wco::Setting.get('WASYACO_SIMPLE_API_SECRET') })
json.newspartials @newsvideo.newspartials.each do |newspartial|
  json.generate_video_url api_newsproducer_studio_1_url({ newspartial_id: newspartial.id.to_s,
                                                           wco_origin: request.base_url,
                                                           api_key:    Wco::Setting.get('WASYACO_SIMPLE_API_KEY'),
                                                           api_secret: Wco::Setting.get('WASYACO_SIMPLE_API_SECRET'),
                                                        })
end