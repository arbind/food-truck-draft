class HoverCraft
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid

  FIT_need_to_explore = -1  # flag to go get hover crafts and explore this
  FIT_zero = 0           # its not a fit
  FIT_missing_craft = 1  # missing info
  FIT_need_to_check = 3  # flag for manual check
  FIT_neutral = 5        # at least its not a bad fit
  FIT_absolute = 8       # known to be a fit

  # geocoder fields
  field :address, default: nil
  field :coordinates, type: Array, default: [] # does geocoder gem auto index this?

  field :status, type: Symbol, default: :unvisited # [:unvisited, :visited]

  field :craft_id, default: nil

  field :skip_this_craft, type: Boolean, default: false
  field :craft_is_for_food, type: Boolean, default: false
  field :craft_is_a_truck, type: Boolean, default: false

  field :fit_score, type: Integer, default: FIT_need_to_check
  field :fit_score_name, type: Integer, default: FIT_need_to_check
  field :fit_score_username, type: Integer, default: FIT_need_to_check
  field :fit_score_website, type: Integer, default: FIT_need_to_check
  field :fit_score_food, type: Integer, default: FIT_need_to_check
  field :fit_score_truck, type: Integer, default: FIT_need_to_check

  field :yelp_id, default: nil
  field :yelp_name, default: nil
  field :yelp_username, default: nil
  field :yelp_href, default: nil
  field :yelp_website, default: nil
  field :yelp_categories, default: nil
  field :yelp_craft_id, default: nil

  field :twitter_referring_user, default: nil
  field :twitter_id, default: nil
  field :twitter_name, default: nil
  field :twitter_username, default: nil
  field :twitter_href, default: nil
  field :twitter_website, default: nil
  field :twitter_craft_id, default: nil
  field :twitter_following, default: nil

  field :facebook_id, default: nil
  field :facebook_name, default: nil
  field :facebook_username, default: nil
  field :facebook_href, default: nil
  field :facebook_website, default: nil
  field :facebook_craft_id, default: nil

  scope :ready_to_make, where(fit_score: 8).and(craft_id: nil)

  geocoded_by :address
  reverse_geocoded_by :coordinates
  before_save :geocode_this_location! # auto-fetch coordinates

  before_save :calculate_fit_scores
  # after_initialize :calculate_fit_scores # use in debug mode to play with algorythm

  def materialize_craft
    web_crafts = []
    yelp_craft = YelpService.web_craft_for_href(yelp_href) if yelp_exists?
    if yelp_craft
      self.yelp_craft_id = yelp_craft_id
      web_crafts << yelp_craft
    end
    twitter_craft = TwitterService.web_craft_for_href(twitter_href) if twitter_exists?
    if twitter_craft
      self.twitter_craft_id = twitter_craft_id
      web_crafts << twitter_craft
    end
    facebook_craft = FacebookService.web_craft_for_href(facebook_href) if facebook_exists?
    if facebook_craft
      self.facebook_craft_id = facebook_craft_id
      web_crafts << facebook_craft
    end

    if web_crafts.empty?
      puts "Could not create any web crafts for HoverCraft(#{_id})"
      return nil 
    end

    # see if a craft is already bound 
    crafts_map = {}
    web_crafts.map{|wc| crafts_map[wc.craft._id] = wc.craft if wc.craft.present?} # collect all the parent crafts for the web_crafts
    crafts = crafts_map.values
    if 1==crafts.size  # return the parent craft if exactly 1 craft already exists
      puts "A craft #{crafts.first._id} previously exists for this HoverCraft #{_id}"
      self.craft_id = crafts.first._id
      save!
      return crafts.first 
    elsif 1<crafts.size  # ambiguos situation if more than one craft already exists
      puts "Multiple crafts (#{crafts.first._id}, #{crafts.first._id}, ... )previously exists for this HoverCraft #{_id}, Now Confused"
      return nil
    end
    # no craft was previously found, safe to materialize one
    craft = Craft.create
    craft.bind(web_crafts)
    self.craft_id = craft._id
    save!
    craft
  end

  def self.explore_twitter_followers(twitter_screen_name, remaining_hits=nil)
    return false unless twitter_screen_name.present?

    num_hits_left = remaining_hits || Twitter.rate_limit_status.remaining_hits
    return false if num_hits_left.zero?

    response = Twitter.friend_ids(twitter_screen_name)
    friends = response.ids if response
    return true if friends.blank?
    return true if 250 < friends.count # don't lookup everyone yet!
    friends.each do |twitter_id|
      dup = HoverCraft.where(twitter_id: twitter_id).first
      next if dup.present?
      h = { twitter_id: twitter_id, fit_score: FIT_need_to_explore, twitter_referring_user: twitter_screen_name }
      HoverCraft.create(h)
    end
    true
  rescue
    false
  end

  def explore
    return unless fit_score.eql? FIT_need_to_explore
    explore_twitter_id if twitter_id.present?
    # +++ explore under other conditions??
  end

  def explore_twitter_id(remaining_hits=nil)
    return false unless twitter_id.present?

    update_attributes(fit_score: FIT_zero) # assume there is no fit

    num_hits_left = remaining_hits || Twitter.rate_limit_status.remaining_hits
    return false if num_hits_left.zero?


    twitter_user = TwitterService.user_for_id(twitter_id)

    return false unless twitter_user.present?

    website = twitter_user['url']
    return false unless website.present?

    screen_name = twitter_user['screen_name']
    description = twitter_user['description'].downcase if twitter_user['description'].present?

    doc = Web.hpricot_doc(website)
    if doc.present?
      facebook_links  = ::FacebookService.hrefs_in_hpricot_doc(doc)
      yelp_links      = ::YelpService.hrefs_in_hpricot_doc(doc)
      # hrefs[:you_tube]    = YouTubeService.hrefs_in_hpricot_doc(doc) unless hrefs[:you_tube].present?
      # hrefs[:flickr]    = FlickrService.hrefs_in_hpricot_doc(doc) unless hrefs[:flickr].present?
      # hrefs[:rss]       = RssService.hrefs_in_hpricot_doc(doc) unless hrefs[:rss].present?
    end
    twitter_hover_craft = TwitterService.hover_craft(screen_name)
    facebook_hover_craft = FacebookService.hover_craft(facebook_links.first) if facebook_links.present?
    yelp_hover_craft = YelpService.hover_craft(yelp_links.first) if yelp_links.present?
    twitter_hover_craft ||= {}
    facebook_hover_craft ||= {}
    yelp_hover_craft ||= {}
    dup = HoverCraft.where(twitter_username: twitter_username).first
    return true if dup.present?
    dup = HoverCraft.where(yelp_username: twitter_username).first
    return true if dup.present?

    udpate_attributes(yelp_hover_craft.merge(twitter_hover_craft).merge(facebook_hover_craft))
    # identify most likely facebook link if there is more than 1
    # create HoverCraft if strong fit or if description['truck'] or yelp_hover_craft.present?
  rescue Exception => e
    puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
    puts e.message
    puts "When exploring hover craft"
    puts e.backtrace
    puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"        
    false
  end

  def self.explore_yelp_listing(biz)
    return unless biz.present?

    dup = HoverCraft.where(yelp_id: biz['id']).first
    return if dup.present?

    yelp_hover_craft = YelpService.hover_craft(biz)
    puts "got yelp_hover_craft #{yelp_hover_craft}"
    return unless yelp_hover_craft.present?
    puts "yelp_hover_craft[:yelp_website]: #{yelp_hover_craft[:yelp_website]}"
    if yelp_hover_craft[:yelp_website].present?
      doc = Web.hpricot_doc(yelp_hover_craft[:yelp_website])
      if doc.present?
        puts "got hpricot doc for #{yelp_hover_craft[:yelp_website]}"
        twitter_links   = ::TwitterService.hrefs_in_hpricot_doc(doc)
        facebook_links  = ::FacebookService.hrefs_in_hpricot_doc(doc)
        # hrefs[:yelp]      = ::YelpService.hrefs_in_hpricot_doc(doc) unless hrefs[:yelp].present?
        # hrefs[:you_tube]    = YouTubeService.hrefs_in_hpricot_doc(doc) unless hrefs[:you_tube].present?
        # hrefs[:flickr]    = FlickrService.hrefs_in_hpricot_doc(doc) unless hrefs[:flickr].present?
        # hrefs[:rss]       = RssService.hrefs_in_hpricot_doc(doc) unless hrefs[:rss].present?
      end
    end
    twitter_hover_craft = TwitterService.hover_craft(twitter_links.first) if twitter_links.present?
    facebook_hover_craft = FacebookService.hover_craft(facebook_links.first) if facebook_links.present?
    twitter_hover_craft ||= {}
    facebook_hover_craft ||= {}
    h = HoverCraft.create(yelp_hover_craft.merge(twitter_hover_craft).merge(facebook_hover_craft))
    puts "---------"
    # identify most likely twitter link if there is more than 1
    # identify most likely facebook link if there is more than 1
    # create HoverCraft if strong fit
    h
  rescue Exception => e
    puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
    puts e.message
    puts "When exploring hover craft"
    puts e.backtrace
    puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"        
  end


  def self.scan_for_food_trucks_near_place(place, state, term="food truck, truck", page=1, total_pages=0)
    return if ( 1<page and (total_pages < page or 1000 < (page*YelpService::V2_MAX_RESULTS_LIMIT) ) )

    results = YelpService.food_trucks_near_place(place, state, term, page)
    return unless results.present?

    results ||= {}
    if 1 == page
      total_results = results['total'] || 0
      total_pages = 1 + (total_results / YelpService::V2_MAX_RESULTS_LIMIT)
      puts "total_results = #{total_results}"
      puts "total_pages = #{total_pages}"
    end

    biz_list = *results['businesses']

    puts "============================"
    puts "exploring #{biz_list.count} results from page #{page} of #{total_pages}"
    biz_list.each{ |biz| explore_yelp_listing(biz) }

    scan_for_food_trucks_near_place(place, state, term, page+1, total_pages)
  end

  def yelp_exists?() yelp_id.present? end
  def twitter_exists?() twitter_username.present? end
  def facebook_exists?() facebook_id.present? end

  def yelp_does_not_exist?() not yelp_exists? end
  def twitter_does_not_exist?() not twitter_exists? end
  def facebook_does_not_exist?() not facebook_exists? end

  def names_match?(name1, name2)
    return false unless (name1.present? and name2.present?)
    val1 = name1.downcase.gsub(/[^0-9a-z]/i, '') # remove non alphanumerics and compress everything
    val2 = name2.downcase.gsub(/[^0-9a-z]/i, '')
    return true if val1.eql? val2
    return true if val1.include? val2
    return true if val2.include? val1
    return false
  end

  def set_all_fit_scores(score)
    self.fit_score = self.fit_score_name = self.fit_score_username = self.fit_score_website = self.fit_score_food = self.fit_score_truck = score
  end
  def calculate_fit_scores
    # calculate matches strengths
    return set_all_fit_scores(FIT_need_to_explore) if fit_score.eql? FIT_need_to_explore
    return set_all_fit_scores(FIT_zero) if skip_this_craft?
    return set_all_fit_scores(FIT_missing_craft) if yelp_does_not_exist? or twitter_does_not_exist?

    calculate_food_fit_score
    calculate_truck_fit_score
    return set_all_fit_scores(FIT_absolute) if FIT_absolute.eql? fit_score_food and FIT_absolute.eql? fit_score_truck

    calculate_website_fit_score
    calculate_name_fit_score
    calculate_username_fit_score

    return (self.fit_score = FIT_absolute) if FIT_absolute.eql? fit_score_website
    return (self.fit_score = FIT_absolute) if yelp_exists? and twitter_exists? and facebook_exists? and FIT_absolute.eql? fit_score_name
    return (self.fit_score = FIT_need_to_check) if FIT_absolute.eql? fit_score_name
    return (self.fit_score = FIT_need_to_check) if FIT_absolute.eql? fit_score_username

  end

  def calculate_website_fit_score 
    return (self.fit_score_website = FIT_need_to_check) if yelp_website.blank? or twitter_website.blank?

    if Web.href_domains_match?(yelp_website, twitter_website)
      self.fit_score_website = FIT_absolute
      self.fit_score_website = FIT_need_to_check if facebook_website.present? and not Web.href_domains_match?(yelp_website, facebook_website)
      return self.fit_score_website
    else # website domains do not match
      self.fit_score_website = FIT_zero
    end
  end

  def calculate_name_fit_score
    return (self.fit_score_name = FIT_need_to_check) if yelp_name.blank? or twitter_name.blank?
      
    if names_match?(yelp_name, twitter_name)
      self.fit_score_name = FIT_absolute
      self.fit_score_name = FIT_need_to_check if facebook_name.present? and not names_match?(yelp_name, facebook_name)
    else
      self.fit_score_name = FIT_zero
    end
    self.fit_score_name
  end

  def calculate_username_fit_score 
    return (self.fit_score_username = FIT_neutral) if facebook_username.blank?
    # yelp has no username for a craft
    if names_match?(twitter_username, facebook_username)
      self.fit_score_username = FIT_absolute
    else
      self.fit_score_username = FIT_zero
    end
    self.fit_score_username
  end

  def calculate_food_fit_score 
    return (self.fit_score_food = FIT_absolute) if craft_is_for_food?
    self.fit_score_food = FIT_need_to_check
    # check yelp categories?
  end

  def calculate_truck_fit_score
    return (self.fit_score_truck = FIT_absolute) if craft_is_a_truck?
    self.fit_score_truck = FIT_need_to_check
  end

  def self.beam_up(url='www.food-truck.me', path='hover_crafts/sync', use_ssl=false, cookies = {}, port=nil)
    HoverCraft.all.each do |h|
      h.beam_up(url, path, use_ssl, cookies, port)
    end
  end

  def beam_up(url, path, use_ssl=false, cookies = {}, port=nil)
    params = { hover_craft: self.to_json }
    r = Web.http_post(url, path, params, use_ssl, cookies, port)
    r.parsed_response['yelp_id'] if r
  end


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
    # +++ enable geocoder geo caching!
    if self.lat.present? and (new? or changes[:coordinates].present?)
      puts "coordinates changed!"
      reverse_geocode # udate the address
    elsif address.present? and (new? or changes[:address].present?)
      puts "address changed!"
      geocode # update lat, lng
    end
    return true
  end

end