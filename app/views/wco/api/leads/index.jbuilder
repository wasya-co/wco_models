
json.results do
  json.array! @leads.each do |lead|
    json.id lead.id.to_s
    json.text lead.email
  end
end
