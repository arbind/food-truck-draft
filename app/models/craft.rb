class Craft
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid

  # search ranking sort score
  field :ranking_score, type: Integer, default: 0

  # geocoder fields
  field :address, default: nil
  field :coordinates, type: Array, default: [] # does geocoder gem auto index this?
  # mongoid stores [long, lat] - which is backwards from normal convention
  # geocorder knows this, but expects [lat, lng]

  field :geo_location_history, :type => Array # for mobile crafts like a Food Truck

  # add all nizer.name to search_tags - be sure to update list when binding to a new nizer
  field :provider_id_tags, type: Array, default: [] # e.g. fb:facebook_id, yelp:yelp_id, @twitter_id etc. should be aliased to this field for a normalized id 
  field :provider_username_tags, type: Array, default: []  # e.g. fb:username, @twitter_handle

  field :essence_tags, type: Array, default: [] # food, fit, fun, travel, home
  field :theme_tags, type: Array, default: [] # truck, taco, sushi: weight-loss, yoga, etc


  field :href_tags, type: Array, default: []
  field :search_tags, type: Array, default: []

  # statuses
  field :status_strength, type: Integer
  field :rejected, type: Boolean, default: false
  field :approved, type: Boolean, default: false

  embeds_one :twitter_craft
  embeds_one :yelp_craft
  embeds_one :facebook_craft
  embeds_one :webpage_craft

  has_many :web_crafts, :dependent => :destroy
  # has_and_belongs_to_many :nizers # organizers

  index :provider_id_tags
  index :provider_username_tags
  index :essence_tags
  index :theme_tags
  index :href_tags
  index :search_tags

  geocoded_by :address
  reverse_geocoded_by :coordinates
  before_save :geocode_this_location! # auto-fetch coordinates

  def self.service() CraftService.instance end
  def service() CraftService.instance end

  def self.materialize_from_twitter_id(tid, default_address=nil, tweet_stream_id=nil)
    service.materialize_from_twitter_id(tid, default_address, tweet_stream_id)
  end

  def self.materialize(provider_id_username_or_href, provider = nil)
    service.materialize(provider_id_username_or_href, provider)
  end

  def self.where_twitter_exists
    crafts = Craft.all.reject{|c| c.twitter_craft.nil?} # find all crafts with a twitter webcraft
  end
  def self.without_twitter
    crafts = Craft.all.reject{|c| c.twitter_craft.present?} # find all crafts with missing twitter webcrafts
  end

  def tweet_stream_id() twitter.present? ? twitter.tweet_stream_id : nil end

  def is_for_food?(add_it = nil) is_in_essence_tags(:food, add_it) end
  def is_for_mobile_cuisine?(add_it = nil) is_in_essence_tags(:mobile_cuisine, add_it) end
  def is_for_fitness?(add_it = nil) is_in_essence_tags(:fitness, add_it) end
  def is_for_fun?(add_it = nil) is_in_essence_tags(:fun, add_it) end
  def is_for_home?(add_it = nil) is_in_essence_tags(:home, add_it) end
  alias_method :is_for_food_truck?, :is_for_mobile_cuisine?
  alias_method :is_for_foodtruck?, :is_for_mobile_cuisine?

  # add, remove or toggle a tag in the essence_tags
  def is_in_essence_tags(tag, add_it = nil)
    if :toggle.eql? add_it
      if essence_tags.include? tag
        is_in_essence_tags(tag, false) 
      else
        is_in_essence_tags(tag, true) 
      end
    elsif true.eql? add_it
      self.essence_tags << tag unless essence_tags.include? tag
      save!
      return true
    elsif false.eql? add_it
      self.essence_tags -= [ tag ]
      save!
      return false
    end
    essence_tags.include? tag
  end

  # add, remove or toggle a tag in the theme_tags
  def is_in_theme_tags(tag, add_it = nil)
    if :toggle.eql? add_it
      if theme_tags.include? tag
        is_in_theme_tags(tag, false) 
      else
        is_in_theme_tags(tag, true) 
      end
    elsif true.eql? add_it
      self.theme_tags << tag unless theme_tags.include? tag
      save!
      return true
    elsif false.eql? add_it
      self.theme_tags -= [ tag ]
      save!
      return false
    end
    theme_tags.include? tag
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

  # geo point hash representation
  def geo_point() { lat:lat, lng:lng } end
  def geo_point=(latlng_hash)
    lt   = latlng_hash[:latitude]   if latlng_hash[:latitude].present?
    lt ||= latlng_hash[:lat]        if latlng_hash[:lat].present?

    ln   = latlng_hash[:longitude]  if latlng_hash[:longitude].present?
    ln ||= latlng_hash[:long]       if latlng_hash[:long].present?
    ln ||= latlng_hash[:lng]        if latlng_hash[:lng].present?

    self.lat = lt
    self.lng = ln
    { lat:lat, lng:lng }
  end
  alias_method :geo_coordinate, :geo_point
  alias_method :geo_coordinate=, :geo_point=
  # /geo point hash representation

  def map_pins
    {
      "#{_id}" => {
        name: name,
        lat: lat,
        lng: lng,
        website: website, 
        now_active: now_active?
      }
    }
  end

  def bind(web_craft)
    web_craft_list = *web_craft 
    web_craft_list.each do |wc|
      self.build_twitter_craft(wc.attributes)   if wc.provider.eql :twitter
      self.build_yelp_craft(wc.attributes)      if wc.provider.eql :yelp
      self.build_facebook_craft(wc.attributes)  if wc.provider.eql :facebook
      self.build_webpage_craft(wc.attributes)   if wc.provider.eql :webpage

      self.provider_id_tags << wc.web_craft_id unless (wc.web_craft_id.present? and self.provider_id_tags.include?(wc.web_craft_id))
      self.provider_username_tags << wc.username unless (wc.username.present? and self.provider_username_tags.include?(wc.username))
      self.href_tags << wc.href unless (wc.href.present? and self.href_tags.include?(wc.href))
      self.href_tags << wc.website unless (wc.website.present? and self.href_tags.include?(wc.website))
      self.address = wc.address if (:yelp==wc.provider || ( wc.address.present? and not self.address.present?) )
      self.coordinates = wc.coordinates if (:yelp==wc.provider || ( wc.coordinates.present? and not self.coordinates.present?) )
    end
    save
  end

  # def migrate_web_crafts
  #   puts "migrating #{_id}"
  #   d = ['_id', '_type', 'craft_id', 'href_tags', 'search_tags', 'created_at', 'updated_at', 'timeline', 'oembed', 'reviews', 'snippet_text', 'snippet_image_url']

  #   wc = web_crafts.twitter_crafts.first
  #   if wc
  #     puts "twitter #{wc._id}"
  #     atts = {}.merge wc.attributes
  #     d.map{|k| atts.delete k}    
  #     self.build_twitter_craft atts
  #   end

  #   wc = web_crafts.yelp_crafts.first
  #   if wc
  #     puts "yelp #{wc._id}"
  #     atts = {}.merge wc.attributes
  #     d.map{|k| atts.delete k}    
  #     self.build_yelp_craft atts
  #   end

  #   wc = web_crafts.facebook_crafts.first
  #   if wc
  #     puts "facebook #{wc._id}"
  #     atts = {}.merge wc.attributes
  #     d.map{|k| atts.delete k}    
  #     self.build_facebook_craft atts
  #   end

  #   wc = web_crafts.webpage_crafts.first
  #   if wc
  #     puts "webpage #{wc._id}"
  #     atts = {}.merge wc.attributes
  #     d.map{|k| atts.delete k}    
  #     self.build_webpage_craft atts
  #   end

  #   save
  # end

  # def twitter() twitter_craft end
  # def yelp() yelp_craft end
  # def facebook() facebook_craft end
  # def webpage() webpage_craft end

  # def yelp() web_crafts.yelp_crafts.first end
  # def flickr() web_crafts.flickr_crafts.first end
  # def webpage() web_crafts.webpage_crafts.first end
  # def twitter() web_crafts.twitter_crafts.first end
  # def facebook() web_crafts.facebook_crafts.first end
  # def you_tube() web_crafts.you_tube_crafts.first end
  # def google_plus() web_crafts.google_plus_crafts.first end

  # def yelp() nil end
  # def flickr() nil end
  # def webpage() nil end
  # def twitter() nil end
  # def facebook() nil end
  # def you_tube() nil end
  # def google_plus() nil end



  # Derive the Craft's Brand
  def name
    x = twitter_craft.name if twitter_craft.present?
    x ||= yelp_craft.name if yelp_craft.present?
    x ||= facebook_craft.name if facebook_craft.present?
    x
  end

  def description
    x = twitter_craft.description if twitter_craft.present?
    x ||= yelp_craft.description if yelp_craft.present?
    x ||= facebook_craft.description if facebook_craft.present?
    x
  end

  def last_tweet_html
    if twitter_craft.present? and twitter_craft.oembed.present?
      x = twitter_craft.oembed['html'].html_safe
    else
      x = nil
    end
    x
  end

  def how_long_ago_was_last_tweet
    return @how_long_ago_was_last_tweet if @how_long_ago_was_last_tweet.present?
    x = Util.how_long_ago_was(last_tweeted_at) if last_tweeted_at.present?
    x ||= nil
    @how_long_ago_was_last_tweet = x
  end

  def now_active?
    time = last_tweeted_at
    return false if time.nil?

    time = time + (-Time.zone_offset(Time.now.zone))
    2.days.ago < time # consider this craft to be active if there was a tweet in the last 2 days
  end

  def last_tweeted_at
    return @last_tweeted_at if @last_tweeted_at.present?
    # if twitter.present? and twitter.timeline.present? and twitter.timeline.first.present? and twitter.timeline.first["created_at"].present?      
    #   @last_tweeted_at = twitter.timeline.first["created_at"]
    #   @last_tweeted_at = @last_tweeted_at.to_time if @last_tweeted_at.present?
    # else
    #   @last_tweeted_at = nil
    # end
    @last_tweeted_at
  end

  def website
    # first see if there is a website specified
    x = yelp_craft.website if yelp_craft.present?
    x ||= twitter_craft.website if twitter_craft.present?
    x ||= facebook_craft.website if facebook_craft.present?
    # if not, look for an href to a service
    x ||= twitter_craft.href if twitter_craft.present?
    x ||= facebok_craft.href if facebook_craft.present?
    x ||= yelp_craft.href if yelp_craft.present?
    x
  end
  def geo_enabled
    craft.twitter_craft.geo_enabled if twitter_craft.present?
  end

  def location 
    x = address
  end

  def profile_image_url
    x = twitter_craft.profile_image_url if twitter_craft.present?
  end
  def profile_background_color
    x = twitter_craft.profile_background_color if twitter_craft.present?
    x ||= 'grey'
    x
  end
  def profile_background_image_url
    x = twitter_craft.profile_background_image_url if twitter_craft.present?
    x ||= ''
    x
  end
  def profile_background_tile
    if twitter_craft.present?
      x = twitter_craft.profile_background_tile 
    else
      x = false 
    end
    x
  end
  # Craft Branding

  def web_craft_for_provider(provider) web_crafts.where(provider: provider).first end

  def calculate_score
    scores = {
      total:0.0, # 0-25

      upcomming_event:0.0, # 0-5

      reviewed_rating:0.0,# 0-5

      reach: 0.0,
      twitter_reach:0.0,# 0-5
      # facebook_reach:0.0,# 0-5 +++

      recent_activity:0.0, # avg of twitter and facebook activity
      twitter_recent_activity:0.0, # 0-5
      # facebook_recent_activity:0.0 # 0-5 +++
    }

    # +++ calculate upcomming event
    if yelp.present? # 1 point for each star, vested with # reviews (at least 100 reviews required for 100% vested)
      vesting = ([yelp.review_count, 100].min)/100.0
      scores[:reviewed_rating] = yelp.rating * vesting
    end

    if twitter_craft.present? # 1 point for each 500 followers (max of 5 points)
      vesting = ([twitter_craft.followers_count, 500].min)/100.0
      scores[:twitter_reach] = 5 * vesting

      # if twitter_craft.timeline and twitter.timeline.first
      #   last_tweeted = twitter_craft.timeline.first['created_at']
      #   time = last_tweeted.to_time
      #   time = time + (-Time.zone_offset(Time.now.zone))
      #   if 30.minutes.ago < time
      #     recent_activity_score = 5
      #   elsif 1.hour.ago < time
      #     recent_activity_score = 4.9
      #   elsif 2.hours.ago < time
      #     recent_activity_score = 4.8
      #   elsif 3.hours.ago < time
      #     recent_activity_score = 4.7
      #   elsif 4.hours.ago < time
      #     recent_activity_score = 4.6
      #   elsif 8.hours.ago < time
      #     recent_activity_score = 4.5
      #   elsif 9.hours.ago < time
      #     recent_activity_score = 4.4
      #   elsif 10.hours.ago < time
      #     recent_activity_score = 4.3
      #   elsif 11.hours.ago < time
      #     recent_activity_score = 4.2
      #   elsif 12.hours.ago < time
      #     recent_activity_score = 4.1
      #   elsif 24.hours.ago < time
      #     recent_activity_score = 4.0
      #   elsif 36.hours.ago < time
      #     recent_activity_score = 3.5
      #   elsif 48.hours.ago < time
      #     recent_activity_score = 3.0
      #   elsif 60.hours.ago < time
      #     recent_activity_score = 2.5
      #   elsif 72.hours.ago < time
      #     recent_activity_score = 2.0
      #   else 
      #     recent_activity_score = 1.0
      #   end
      #   scores[:twitter_recent_activity] = recent_activity_score
      # end
    end
    scores[:reach] = scores[:twitter_recent_activity]
    scores[:recent_activity] = scores[:twitter_recent_activity]

    scores[:total] = (scores[:upcomming_event] + scores[:reviewed_rating] + scores[:reach] + scores[:recent_activity])
    self.ranking_score = (100*scores[:total]).to_i
    save!
  end

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


# see for google maps stuff:
# http://blog.joshsoftware.com/2011/04/13/geolocation-rails-and-mongodb-a-receipe-for-success/

# see :
# GlobalMaps4Rails

# see:
# http://stackoverflow.com/questions/6640697/how-do-i-query-objects-near-a-point-with-ruby-geocoder-mongoid


# see:
# http://stackoverflow.com/questions/6366870/how-to-search-for-nearby-users-using-mongoid-rails-and-google-maps

# lat, lng = Geocoder.search('some location').first.coordinates
# result = Business.near(:location => [lat, lng])

# ‘rake db:mongoid:create_indexes’