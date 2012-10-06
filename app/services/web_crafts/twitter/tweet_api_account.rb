class TweetApiAccount
  MUTEX = Mutex.new
  @@admin_account_idx = 0
  @@admin_account_last_accessed_at = nil

  # used by application (not Users) to connect to twitter api (via Twitter or TweetStream Gem)
  # default Twitter password: 'foodTRUCK2012'
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid

  def self.stream_service() TweetStreamService.instance end
  def self.twitter_service() TwitterService.instance end
    

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
  scope :admins, where(is_tweet_streamer: false)

  def remote_pull!
    # client = Twitter::Client.new(twitter_oauth_config)
    client = TwitterService.instance.twitter_client(self)
    puts client
    user = client.user
    puts user
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
  rescue Exception => e
    puts e.message
    false
  end

  def self.twitter_api_rate_limit
    # +++ move to app config
    @@admin_account_access_rate_limit ||= 350 # times per hour
  end

  def self.next_admin_account!
    # ! this method may sleep the thread in order to stay within twitter rate limits !
    # add more api admin accounts (non streaming) to help avoid sleeping
    MUTEX.synchronize do
      admin_accounts = admins.asc(:created_at)
      num_admins =  admin_accounts.count
      return nil if num_admins.zero?
      @@admin_account_idx += 1
      @@admin_account_idx = 0 if @@admin_account_idx.eql? num_admins

      access_frequency =  (3600.0/(num_admins * twitter_api_rate_limit)).to_i

      time_elapsed_since_last_access = 1000000
      time_elapsed_since_last_access = (Time.now - @@admin_account_last_accessed_at) if @@admin_account_last_accessed_at.present?

      if (time_elapsed_since_last_access < access_frequency)
        wait_time =  (1 + access_frequency - time_elapsed_since_last_access).to_i
        puts "--- Enforcing twitter Rate Limit(#{twitter_api_rate_limit}/hour): Sleeping for #{wait_time} sec"
        sleep wait_time
      end

      account = admin_accounts[@@admin_account_idx]
      @@admin_account_last_accessed_at = Time.now
      account
    end
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
    new_friend_ids = []
    friend_ids.each do |fid|
      twitter_craft = TwitterCraft.where(twitter_id: fid).first
      JobQueue.service.enqueue(:make_craft_for_twitter_id, {twitter_id: fid, default_address: address, tweet_stream_id: _id})  if twitter_craft.nil?
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
