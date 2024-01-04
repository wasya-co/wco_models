
require 'httparty'

##
## OpenAI GPT3 GPT3.5 GPT4
##
class Wco::AiWriter

  def self.prompt prompt
    out = HTTParty.post("https://api.openai.com/v1/chat/completions", {
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer #{OPENAI_API_KEY}",
      },
      body: {
        model: 'gpt-3.5-turbo',
        messages: [
          { role: "system", content: "You are a knowledgable office assistant." },
          { role: 'user', content: prompt },
        ] }.to_json
    })
    out = JSON.parse out.response.body
    out.deep_symbolize_keys!
    out = out[:choices][0][:message][:content]
    return out
  end

  def run_headline headline
    prompt = "Rephrase the following article title using one sentence: #{headline.name}"
    new_title = self.class.prompt prompt
    puts! new_title, 'new_title'

    prompt = "Write an article about the following topic: #{headline.name}"
    new_body = self.class.prompt prompt
    puts! new_body[0...200], 'new_body'

    Wco::Report.create!({
      title: new_title,
      slug: new_title,
      body:  new_body,

      # for infinite shelter, or for wco
      # @TODO: tagged to be published!
    })

    headline.delete
  end

end
