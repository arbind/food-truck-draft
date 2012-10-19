# This class implements a cache with simple delegation to the Redis store, but
# when it creates a key/value pair, it also sends an EXPIRE command with a TTL.
# It should be fairly simple to do the same thing with Memcached.
class AutoexpireCache
  def initialize(store)
    @store = store
    @ttl = 86400
  end

  def [](url)
    @store.[](url)
  end

  def []=(url, value)
    @store.[]=(url, value)
    @store.expire(url, @ttl)
  end

  def keys
    @store.keys
  end

  def del(url)
    @store.del(url)
  end
end

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
  # config.cache = REDIS
  config.cache = AutoexpireCache.new(REDIS)
  config.cache_prefix = "geocoder:"
end

def clear_geocoder_cache
  Geocoder.cache.expire(:all) # expire all cached results
end
