
json.email @lead.email
json.leadset do
  json.tags @lead.leadset.tags.each do |tag|
    json.id tag.id.to_s
    json.slug tag.slug
  end
end
json.tags @lead.tags.each do |tag|
  json.id tag.id.to_s
  json.slug tag.slug
end
