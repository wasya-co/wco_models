
params.permit!
json.cache! [ params, @product ] do

  json.id         @product.id.to_s
  json.name       @product.to_s

  json.prices do
    json.array! @product.prices do |price|
      json.id   price.id.to_s
      json.name price.to_s
    end
  end

end

