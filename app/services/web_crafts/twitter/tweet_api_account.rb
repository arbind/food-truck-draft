class TweetApiAccount
  # used by application (not Users) to connect to twitter api (via Twitter or TweetStream Gem)
  # default Twitter password: 'foodTRUCK2012'
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid

  field :twitter_id, type: Integer, default: nil
  field :is_tweet_streamer, type: Boolean, default: false
  field :login_ok, type: Boolean, default: false
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

  scope :streams, where(is_tweet_streamer: true).and(login_ok: true)
  scope :admins, where(is_tweet_streamer: false).and(login_ok: true)



  def stream_service() TweetStreamService.instance end
  def self.stream_service() TweetStreamService.instance end

  def twitter_service() TwitterService.instance end
  def self.twitter_service() TwitterService.instance end
    
  def update_from_twitter_client(client)
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
  end

  def remote_pull!
    raise "!! account login is unverified #{screen_name}[#{twitter_id}]" unless (login_ok or verify_login)
    # client = Twitter::Client.new(twitter_oauth_config)
    client = twitter_service.twitter_client(self)
    update_from_twitter_client(client)
  rescue Exception => e
    puts e.message
    false
  end

  def twitter_client() twitter_service.twitter_client(self) end
  def self.next_admin_account!() twitter_service.next_admin_account! end

  def self.verify_logins
    TweetApiAccount.all.each { |account| account.verify_login }
  end

  def verify_login
    twitter_service.delete_twitter_client(self) # remove any old clients that may have stale auth info
    client = twitter_service.twitter_client(self)
    login_ok = update_from_twitter_client(client)
    puts ":: #{scren_name}: Login OK = #{login_ok}"
    update_attributes(login_ok: login_ok)
    login_ok
  rescue Exception => e
    puts "!! #{screen_name}: login failed #{e.message}"
    update_attributes(login_ok: false)
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

  # Enqueue job to create a new Craft for each new friend this tweetstream is following
  def queue_friend_ids_to_materialize
    return unless is_tweet_streamer

    remote_pull!
    new_friends_count = 0
    friend_ids.each do |fid|
      twitter_craft = TwitterCraft.where(twitter_id: fid).first
      if twitter_craft.nil?
        JobQueue.service.enqueue(:make_craft_for_twitter_id, {twitter_id: fid, default_address: address, tweet_stream_id: _id})
        new_friends_count +=1
      end
      puts "^^Queued #{new_friends_count} to make_craft_for_twitter_id from #{screen_name} tweet stream" unless new_friends_count.zero?
    end
      # craft = Craft.materialize_from_twitter_id(fid)
        # client = TwitterService.instance.admin_client
        # user = client.user(fid)
        # update HoverCrafts also
  end

  def streaming_status
    self.is_tweet_streamer ? TweetStreamService.instance.stream_status(self.screen_name) : :off
  end

  def twitter_oauth_config
    self.oauth_config.twitter_oauth_config
  end
 
  def self.beam_up(url='www.food-truck.me', path='tweet_api_accounts/sync.json', use_ssl=false, cookies = {}, port=nil)
    TweetApiAccount.all.each do |s|
      s.beam_up(url, path, use_ssl, cookies, port)
    end
  end
  def beam_up(url='www.food-truck.me', path='tweet_api_accounts/sync.json', use_ssl=false, cookies = {}, port=nil)
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
