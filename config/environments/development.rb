FoodTruck::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  SECRETS = {
    :YELP => {  # http://www.yelp.com/developers/manage_api_keys facebook[arbind.thakur] or arbind.thakur@gmail.com/!light
      :V1 => { # Yelp API V1.0 uses Yelp Web Service ID:
        :yws_id => "nlYdgQ9zX6qf0ZE6tCs79A"
      },
      :V2 => { # Yelp API v2.0 uses OAUTH:
        :consumer_key     => "EdtIXf4NMUBXh8XoysxW2Q",
        :consumer_secret  => "hMUNaKi1Oa_d7OvlHH0d2_7d7-M",
        :token             => "p4KFTaHrRR6oTGNOzGq28G9lrdgssyId",
        :token_secret     => "8Zvy3k9wMPQflJs7Ztgq9w2uE1c"
      }
    },
    :TWITTER => {

    }
  }

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  # Using mongoid instead of active record - commented out
  # config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # Using mongoid instead of active record - commented out
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true
end
