
require "httparty"

class Wco::AiWriter
  include ::HTTParty

  base_uri "https://api.openai.com"

  def self.do_call(task, content)
    response = post(
      "/v1/chat/completions",
      headers: {
        "Authorization" => "Bearer #{Wco::Setting.get('OPENAI_API_KEY')}",
        "Content-Type" => "application/json"
      },
      body: {
        model: "gpt-4o",
        messages: [
          {
            role: "system",
            content: task
          },
          {
            role: "user",
            content: content
          }
        ]
      }.to_json
    )
    puts! response, 'response'

    response.dig("choices", 0, "message", "content")
  end
end