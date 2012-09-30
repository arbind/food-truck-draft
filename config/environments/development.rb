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
    :STRIPE => { #stripe Test Account
      :SECRET => '5LeZ5IabCsvLNA8YHZOwaILWpGPaFFlG',
      :PUBLISH => 'pk_fA9y8hjM5PLXy9Ubdh7VcZyvNH0dH'
    },
    :TWITTER => {   # @rylyz: https://dev.twitter.com/apps/settings 
      :CONSUMER_KEY => '',
      :CONSUMER_SECRET => ''
    },
    :FACEBOOK => { # arbind.thakur: https://developers.facebook.com/apps/202629609869569
      :APP_ID => '202629609869569',
      :APP_SECRET => '6b8ba4b741b5f4da8a53723ec07eff87'
    },
    :GOOGLE_OAUTH2 => { # arbind.thakur@gmail.com: https://code.google.com/apis/console/?pli=1#project:954168963539
      :CLIENT_ID => '954168963539.apps.googleusercontent.com',
      :CLIENT_SECRET => 'LyqaMg3l9PWLgGPnBf0MGJyr'
    },
    :TUMBLR => { # : http://www.tumblr.com/oauth/apps
      :CONSUMER_KEY => "",
      :SECRET => ""
    },
    :RUNKEEPER => { # : http://runkeeper.com/partner/applications
      :CLIENT_ID => "",
      :CLIENT_SECRET => ""
    },
    :WINDOWSLIVE => { # : https://manage.dev.live.com/Applications/Index: http://msdn.microsoft.com/en-us/library/hh243641.aspx
      :CLIENT_ID => "",
      :SECRET => ""
    },
    :YAHOO => { # google signin(play@rylyz.com): https://developer.apps.yahoo.com/projects !select 1 service(√Social Directory), then updated keys
      :CONSUMER_KEY => "",
      :CONSUMER_SECRET => ""
    },    
    :LINKEDIN => { # : https://www.linkedin.com/secure/developer
      :API_KEY => "",
      :SECRET_KEY => ""
    },
    :MEETUP => { #  http://www.meetup.com/meetup_api/oauth_consumers/
      :KEY => "",
      :SECRET => ""
    },    

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
