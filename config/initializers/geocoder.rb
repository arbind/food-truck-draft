Geocoder.configure do |config|

  # geocoding service (see below for supported options):
  config.lookup = :google

  # Only use an API key if paying for google premier (100K requests/day):
  # https://developers.google.com/maps/documentation/javascript/tutorial#api_key
  # arbind.thakur@gmail.com: https://code.google.com/apis/console/?pli=1#project:954168963539:access
  # config.api_key = "AIzaSyA6SvDNT6S-hTO1EydsE93i2yx7vaoDfNo" # food-truck.me

  # geocoding service request timeout, in seconds (default 3):
  # config.timeout = 5

  # set default units to kilometers:
  # config.units = :km

  # caching (see below for details):
  config.cache = Redis.new
  config.cache_prefix = "geocoder:"
end

def clear_geocoder_cache
  Geocoder.cache.expire(:all) # expire all cached results
end
