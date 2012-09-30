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
  # 6cTaN__96vXxK6UOJPqnVw
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx
  config.action_dispatch.x_sendfile_header = nil

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )
  # config.assets.precompile += %w( *.css *.js )
  config.assets.precompile += ['google/analytics.js']

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5
end
