class Craft
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid

  # geocoder fields
  field :address, default: nil
  field :coordinates, type: Array, default: [] # does geocoder gem auto index this?
  # mongoid stores [long, lat] - which is backwards from normal convention
  # geocorder knows this, but expects [lat, lng]

  field :geo_location_history, :type => Array # for mobile crafts like a Food Truck

  # add all nizer.name to search_tags - be sure to update list when binding to a new nizer
  field :provider_id_tags, type: Array, default: [], index: true # e.g. fb:facebook_id, yelp:yelp_id, @twitter_id etc. should be aliased to this field for a normalized id 
  field :provider_username_tags, type: Array, default: [], index: true  # e.g. fb:username, @twitter_handle

  field :href_tags, type: Array, default: [], index: true
  field :search_tags, type: Array, default: [], index: true
  
  has_many :web_crafts, :dependent => :destroy
  has_and_belongs_to_many :nizers # organizers

  geocoded_by :address
  reverse_geocoded_by :coordinates
  before_save :geocode_this_location! # auto-fetch coordinates

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
  def geo_point() [latitude:lat, longitude:lng] end
  def geo_point=(latlng_hash)
    lat   = latlng_hash[:latitude]   if latlng_hash[:latitude].present?
    lat ||= latlng_hash[:lat]        if latlng_hash[:lat].present?

    lng   = latlng_hash[:longitude]  if latlng_hash[:longitude].present?
    lng ||= latlng_hash[:long]       if latlng_hash[:long].present?
    lng ||= latlng_hash[:lng]        if latlng_hash[:lng].present?

    self.lat = lat
    self.lng = lng
  end
  alias_method :geo_coordinate, :geo_point
  alias_method :geo_coordinate=, :geo_point=
  # /geo point hash representation


  def bind(web_craft)
    web_craft_list = *web_craft 
    web_craft_list.each do |web_craft|
      self.web_crafts << web_craft

      self.provider_id_tags << web_craft.web_craft_id if web_craft.web_craft_id.present?
      self.provider_username_tags << web_craft.username if web_craft.username.present?
      self.href_tags << web_craft.href if web_craft.href.present?
      self.href_tags << web_craft.website if web_craft.website.present?
      self.address = web_craft.address if (:yelp==web_craft.provider || ( web_craft.address.present? and not self.address.present?) )
      self.coordinates = web_craft.coordinates if (:yelp==web_craft.provider || ( web_craft.coordinates.present? and not self.coordinates.present?) )
      # +++ set address / location
    end
    save
  end

  def self.materialize(provider_id_username_or_href)
    web_craft = nil
    if provider_id_username_or_href.looks_like_url? # look for web_craft by href
      web_craft = WebCraft.where(hrefs: provider_id_username_or_href).first
    else # look for web_craft by screen name or social id
      web_craft = WebCraft.where(provider_username_tags: provider_id_username_or_href).or(provider_id_tags: provider_id_username_or_href).first
    end
    return web_craft.craft if (web_craft && web_craft.craft)

    # didn't find a craft, lets scrape the web to get web_crafts for provider_id_username_or_href
    web_crafts_map = Web.web_crafts_for_website(provider_id_username_or_href)
    web_crafts = web_crafts_map[:web_crafts] # all the web_crafts in an array
    return nil unless web_crafts.present? # do not create a new craft if there are no web_crafts

    #see if an already existing craft was found with any of these web_crafts
    crafts = web_crafts.collect(&:craft).reject{|i| i.nil?} # collect all the parent crafts for the web_crafts
    return crafts.first if crafts.present?  # return the parent craft if any webcraft was found

    # we have some web_crafts, and none of them have a parent craft, lets create a new one
    craft = Craft.create
    craft.bind(web_crafts)
    craft
  end

  def yelp() web_crafts.yelp_crafts.first end
  def flickr() web_crafts.flickr_crafts.first end
  def webpage() web_crafts.webpage_crafts.first end
  def twitter() web_crafts.twitter_crafts.first end
  def facebook() web_crafts.facebook_crafts.first end
  def you_tube() web_crafts.you_tube_crafts.first end
  def google_plus() web_crafts.google_plus_crafts.first end


  # Derive the Craft's Brand
  def name
    x = twitter.name if twitter.present?
    x ||= yelp.name if yelp.present?
    x ||= facebook.name if facebook.present?
  end

  def description
    x = twitter.description if twitter.present?
    x ||= yelp.description if yelp.present?
    x ||= facebook.description if facebook.present?
  end

  def last_tweet_html
    if twitter.present? and twitter.oembed.present?
      x = twitter.oembed['html'].html_safe
    end
  end

  def how_long_ago_was_last_tweet
    return @how_long_ago_was_last_tweet if @how_long_ago_was_last_tweet.present?

    if twitter.present? and twitter.timeline.present? and twitter.timeline.first.present? and twitter.timeline.first["created_at"].present?      
      last_tweeted_at = twitter.timeline.first["created_at"]
      x = Util.how_long_ago_was(last_tweeted_at)
    end
    x ||= nil
    @how_long_ago_was_last_tweet = x
  end

  def website
    # first see if there is a website specified
    x = yelp.website if yelp.present?
    x ||= twitter.website if twitter.present?
    x ||= facebook.website if facebook.present?
    # if not, look for an href to a service
    x ||= twitter.href if twitter.present?
    x ||= facebok.href if facebook.present?
    x ||= yelp.href if yelp.present?
  end
  def geo_enabled
    twitter.geo_enabled if twitter.present?
  end

  def location 
    x = address
  end

  def profile_image_url
    x = twitter.profile_image_url if twitter.present?
  end
  def profile_background_color
    x = twitter.profile_background_color if twitter.present?
    x ||= 'grey'
  end
  def profile_background_image_url
    x = twitter.profile_background_image_url if twitter.present?
    x ||= ''
  end
  def profile_background_tile
    if twitter.present?
      x = twitter.profile_background_tile 
    else
      x = false 
    end
  end
  # Craft Branding


  def web_craft_for_provider(provider) web_crafts.where(provider: provider).first end
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