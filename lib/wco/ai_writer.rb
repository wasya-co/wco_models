
# require 'httparty'

##
## OpenAI GPT3 GPT3.5 GPT4
##
class Wco::AiWriter

  def self.run_prompt prompt
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
  def run_prompt p; self.class.run_prompt p; end


  def self.run_headline headline
    prompt = "Rephrase the following article title using one sentence: #{headline.name}"
    new_title = self.run_prompt prompt
    puts! new_title, 'new_title'

    prompt = "Write an article about the following topic: #{headline.name}"
    new_body = self.run_prompt prompt
    new_body.gsub!("\r", '')
    new_body = new_body.split("\n\n").map { |ppp| "<p>#{ppp}</p>" }.join
    new_body = new_body.gsub("\n", "<br />")
    puts! new_body[0...200], 'new_body'

    report = Wco::Report.create!({
      title: new_title,
      slug: new_title,
      body:  new_body,
    })

    # headline.delete

    return report
  end
  def run_headline h; self.class.run_headline h; end


end
