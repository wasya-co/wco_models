# frozen_string_literal: true

Devise.setup do |config|
  config.secret_key = '5cc4d4e1c05582cf32ed79a827736e41f3d882796e2426d578154e98492c4723c254a3ccfa83fee015ad592e89e6e11d63338312c2eff2001ad6f463a73f2cfe'
  config.mailer_sender = 'no-reply@wasya.co'
  require 'devise/orm/mongoid'
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]

  # Limiting the stretches to just one in testing will increase the performance of
  # your test suite dramatically. However, it is STRONGLY RECOMMENDED to not use
  # a value less than 10 in other environments. Note that, for bcrypt (the default
  # algorithm), the cost increases exponentially with the number of stretches (e.g.
  # a value of 20 is already extremely slow: approx. 60 seconds for 1 calculation).
  config.stretches = Rails.env.test? ? 1 : 12

  config.send_email_changed_notification    = true
  config.send_password_change_notification  = true
  config.reconfirmable = true
  config.expire_all_remember_me_on_sign_out = true
  config.password_length = 8..32
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  config.reset_password_within = 6.hours

  config.sign_out_via = :delete

  # ==> OmniAuth
  # Add a new OmniAuth provider. Check the wiki for more information on setting
  # up on your models and hooks.
  # config.omniauth :github, 'APP_ID', 'APP_SECRET', scope: 'user,public_repo'

  # ==> Warden configuration
  # If you want to use other strategies, that are not supported by Devise, or
  # change the failure app, you can configure them inside the config.warden block.
  #
  # config.warden do |manager|
  #   manager.intercept_401 = false
  #   manager.default_strategies(scope: :user).unshift :some_external_strategy
  # end

  # ==> Mountable engine configurations
  # When using Devise inside an engine, let's call it `MyEngine`, and this engine
  # is mountable, there are some extra configurations to be taken into account.
  # The following options are available, assuming the engine is mounted as:
  #
  #     mount MyEngine, at: '/my_engine'
  #
  # The router that invoked `devise_for`, in the example above, would be:
  # config.router_name = :my_engine
  #
  # When using OmniAuth, Devise cannot automatically set OmniAuth path,
  # so you need to do it manually. For the users scope, it would be:
  # config.omniauth_path_prefix = '/my_engine/users/auth'

  config.responder.error_status    = :unprocessable_entity
  config.responder.redirect_status = :see_other

  config.omniauth( :keycloak_openid, "wco", client_options: {
    site: "https://auth.wasya.co",
    realm: "wco",
    base_url: '',
  }, strategy_class: OmniAuth::Strategies::KeycloakOpenId )



end
