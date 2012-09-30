class CraftStream
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid

  field :twitter_username, default: nil
  field :twitter_password, default: nil
  field :oauth_config, type: Hash, default: { auth_method: :oauth }

  # geocoder fields
  field :address, default: nil
  field :coordinates, type: Array, default: [] # does geocoder gem auto index this?
  # mongoid stores [long, lat] - which is backwards from normal convention
  # geocorder knows this, but expects [lat, lng]

  geocoded_by :address
  reverse_geocoded_by :coordinates
  before_save :geocode_this_location! # auto-fetch coordinates

  def follow(twitter_username_or_id)
  end

  def unfollow(twitter_username_or_id)
  end

  def following_ids
    # return array of following id
  end

  def self.beam_up(url='www.food-truck.me', path='craft_streams/sync.json', use_ssl=false, cookies = {}, port=nil)
    CraftStream.all.each do |s|
      s.beam_up(url, path, use_ssl, cookies, port)
    end
  end
  def beam_up(url, path, use_ssl=false, cookies = {}, port=nil)
    params = { craft_stream: self.to_json }
    r = Web.http_post(url, path, params, use_ssl, cookies, port)
    puts r
    r
  end

# geocoding  aliases
  alias_method :ip_address, :address
  alias_method :ip_address=, :address=

  def latitude() coordinates.last end
  alias_method :lat, :latitude

  def latitude=(lat) coordinates ||= [0,0]; coordinates[1] = lat end
  alias_method :lat=, :latitude=

  def longitude() coordinates.first end
  alias_method :lng, :longitude
  alias_method :long, :longitude

  def longitude=(lng) coordinates[0] = lng end
  alias_method :lng=, :longitude=
  alias_method :long=, :longitude=
  # /geocoding  aliases
private
  def geocode_this_location!
    # +++ enable geocoder geo caching! so we are not geocoding both the webcraft and the craft
    if self.lat.present? and (new? or changes[:coordinates].present?)
      puts "coordinates changed!"
      reverse_geocode # udate the address
      # +++ add {time, coordinates, address} to geo_location_history
    elsif address.present? and (new? or changes[:address].present?)
      puts "address changed!"
      geocode # update lat, lng
    end
    return true
  end

end
