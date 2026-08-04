
Rails.application.config.assets.version = '2.0'

# Rails.application.config.assets.paths << Rails.root.join('wco_models/app/assets/javascrpits')

Rails.application.config.assets.precompile += %w(
  wco_models/application.js
  wco_models/application.css

  wco_models/newsproducer/studio_1.js
)
