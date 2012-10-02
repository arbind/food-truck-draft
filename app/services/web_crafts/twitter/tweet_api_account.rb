class TweetApiAccount
  # used by application (not Users) to connect to twitter api (via Twitter or TweetStream Gem)
  # default Twitter password: 'foodTRUCK2012'
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid

  field :twitter_id, type: Integer, default: nil
  field :is_tweet_streamer, type: Boolean, default: false
  field :screen_name, default: nil
  field :name, default: nil
  field :description, default: nil
  field :friends_count, type: Integer, default: 0
  field :followers_count, type: Integer, default: 0
  field :friend_ids, type: Array, default: []
  field :oauth_config, type: Hash, default: { auth_method: :oauth }
  # geocoder fields
  field :address, default: nil
  field :coordinates, type: Array, default: [] # does geocoder gem auto index this?
  # mongoid stores [long, lat] - which is backwards from normal convention
  # geocorder knows this, but expects [lat, lng]

  geocoded_by :address
  reverse_geocoded_by :coordinates
  before_save :geocode_this_location! # auto-fetch coordinates

  scope :streams, where(is_tweet_streamer: true)
  scope :admin, where(is_tweet_streamer: false)

  def remote_pull!
    client = Twitter::Client.new(twitter_oauth_config)
    tid = twitter_id.present? ? twitter_id : screen_name
    user = client.user
    self.twitter_id = user.id
    self.screen_name = user.screen_name
    self.name = user.name
    self.description = user.description
    self.address = user.location
    self.friends_count = user.friends_count
    self.followers_count = user.followers_count

    # manage friend list
    friends = client.friend_ids
    unfriended = self.friend_ids - friends.ids # +++ TODO unbind TwitterCrafts that are bound to this TweetStreamAccount (if this is a TweetStreamAccount)
    self.friend_ids = friends.ids
    self.save!
  rescue
    false
  end

  def consumer_key() oauth_config['consumer_key'] end
  def consumer_key=(val) oauth_config['consumer_key'] = val end
  def consumer_secret() oauth_config['consumer_secret'] end
  def consumer_secret=(val) oauth_config['consumer_secret'] = val end
  def oauth_token() oauth_config['oauth_token'] end
  def oauth_token=(val) oauth_config['oauth_token'] = val end
  def oauth_token_secret() oauth_config['oauth_token_secret'] end
  def oauth_token_secret=(val) oauth_config['oauth_token_secret'] = val end

  def follow(twitter_username_or_id)
  end

  def unfollow(twitter_username_or_id)
  end

  def following_ids
    # return array of following id
  end

  def twitter_oauth_config
    self.oauth_config.twitter_oauth_config
  end
 
  def self.beam_up(url='www.food-truck.me', path='tweet_api_accounts/sync_tweet_admin_account.json', use_ssl=false, cookies = {}, port=nil)
    TweetApiAccount.all.each do |s|
      s.beam_up(url, path, use_ssl, cookies, port)
    end
  end
  def beam_up(url, path, use_ssl=false, cookies = {}, port=nil)
    params = {}
    params[:tweet_api_account] = self.to_json
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
