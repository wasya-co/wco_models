

@leads.each do |lead|
  json.set! lead.id.to_s do
    json.email lead.email
  end
end

