class HoverCraft
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid

  # constants
  FIT_duplicate_crafts = -2 # flag when 2 hover crafts bind to the same already existing craft
  FIT_need_to_explore = -1  # flag to go get hover crafts and explore this
  FIT_zero = 0              # its not a fit
  FIT_missing_craft = 1     # missing info
  FIT_check_manually = 3     # flag for manual check
  FIT_neutral = 5           # at least its not a bad fit
  FIT_absolute = 8          # known to be a fit

  # identifiers
  field :craft_id, default: nil
  field :tweet_stream_id, type: Integer, default: nil

  # manual overrides
  field :skip_this_craft, type: Boolean, default: false
  field :approve_this_craft, type: Boolean, default: false

  # geocoder fields
  field :address, default: nil
  field :coordinates, type: Array, default: [] # does geocoder gem auto index this?

  # webcraft info
  field :webpage_url, default: nil
  field :webpage_craft_id, default: nil

  field :yelp_id, default: nil
  field :yelp_name, default: nil
  field :yelp_username, default: nil
  field :yelp_href, default: nil
  field :yelp_website, default: nil
  field :yelp_categories, default: nil
  field :yelp_craft_id, default: nil

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

  # error states
  field :error_duplicate_crafts, type: Boolean, default: false

  # score
  field :fit_score, type: Integer, default: FIT_check_manually
  field :fit_score_name, type: Integer, default: FIT_check_manually
  field :fit_score_username, type: Integer, default: FIT_check_manually
  field :fit_score_website, type: Integer, default: FIT_check_manually
  # field :fit_score_food, type: Integer, default: FIT_check_manually
  # field :fit_score_mobile, type: Integer, default: FIT_check_manually

  # scopes
  scope :need_to_explore, where(fit_score: FIT_need_to_explore)
  scope :check_manually,  where(fit_score: FIT_check_manually)
  scope :missing_craft,   where(fit_score: FIT_missing_craft)
  scope :zero_fit,        where(fit_score: FIT_zero)
  scope :neutral_fit,     where(fit_score: FIT_neutral)
  scope :absolute_fit,    where(fit_score: FIT_absolute)

  # crafts with both twitter and yelp
  scope :twelps,                 excludes(craft_id: nil).and(skip_this_craft: false).excludes(yelp_craft_id: nil).excludes(twitter_craft_id: nil).desc(:yelp_name)

  scope :trigger_with_tweet_stream, where(fit_score: 8).and(craft_id: nil).and(skip_this_craft: false) # implies: and(tweet_stream_id: nil)
  scope :approve_to_promote,           where(:fit_score.lt => 8).excludes(yelp_id: nil).and(craft_id: nil).and(skip_this_craft: false).desc(:fit_score)

  # already created crafts - could be enhanced?
  scope :missing_tweet_stream,    excludes(craft_id: nil).and(skip_this_craft: false).where(tweet_stream_id: nil).desc(:fit_score)
  scope :missing_yelp_craft,      excludes(craft_id: nil).and(skip_this_craft: false).where(yelp_craft_id: nil).desc(:fit_score)
  scope :missing_twitter_craft,   excludes(craft_id: nil).and(skip_this_craft: false).where(twitter_craft_id: nil).desc(:fit_score)
  scope :missing_facebook_craft,  excludes(craft_id: nil).and(skip_this_craft: false).where(facebook_craft_id: nil).desc(:fit_score)

  scope :crafted,                 excludes(craft_id: nil).and(skip_this_craft: false).desc(:fit_score)
  scope :uncrafted,               where(craft_id: nil).and(skip_this_craft: false).desc(:fit_score)

  scope :skipped,                 where(skip_this_craft: true).desc(:fit_score)

  geocoded_by :address
  reverse_geocoded_by :coordinates
  before_save :geocode_this_location! # auto-fetch coordinates

  before_save :calculate_fit_scores
  after_save :trigger_craft_materialization
  # after_initialize :calculate_fit_scores # use in debug mode to play with algorythm

  def service() HoverCraftService.instance end
  def self.service() HoverCraftService.instance end

  def is_ready_to_make? 
    fit_score.eql?(8) and tweet_stream_id.present? and craft_id.nil?
  end

  def completed?()  crafted? and followed?    end
  def crafted?()    craft_id.present?         end
  def followed?()   tweet_stream_id.present?  end
  def fully_populated?
    followed? and twitter_username.present? and yelp_id.present? and facebook_name.present? and webpage_url.present?
  end

  def yelp_exists?()      yelp_id.present?          end
  def twitter_exists?()   twitter_username.present? end
  def facebook_exists?()  facebook_id.present?      end
  def webpage_exists?()    webpage_url.present?      end

  def yelp_does_not_exist?()      not yelp_exists?      end
  def twitter_does_not_exist?()   not twitter_exists?   end
  def facebook_does_not_exist?()  not facebook_exists?  end
  def webpage_does_not_exist?()   not webpge_exists?    end

  def add_twitter_info()  service.add_twitter_info(self)  end
  def add_facebook_info() service.add_facebook_info(self) end
  def add_webpage_info()  service.add_webpage_info(self)  end
  def add_yelp_info()     service.add_yelp_info(self)     end

  def materialize_craft
    updated_ids = {}
    web_crafts = []
    if  yelp_craft_id.present?
      yelp_craft = YelpCraft.find(yelp_craft_id) rescue nil
    else
      yelp_craft = YelpService.web_craft_for_href(yelp_href) if yelp_exists?
    end
    if yelp_craft.present?
      updated_ids[:yelp_craft_id] = yelp_craft._id.to_s
      web_crafts << yelp_craft
    end

    if twitter_craft_id.present?
      twitter_craft = TwitterCraft.find(twitter_craft_id) rescue nil
    else
      twitter_craft = TwitterService.web_craft_for_href(twitter_href) if twitter_exists?
    end

    if twitter_craft
      updated_ids[:twitter_craft_id] = twitter_craft._id.to_s
      web_crafts << twitter_craft
    end

    if facebook_craft_id.present?
      facebook_craft = FacebookCraft.find(facebook_craft_id) rescue nil
    else
      facebook_craft = FacebookService.web_craft_for_href(facebook_href) if facebook_exists?
    end
    if facebook_craft
      updated_ids[:facebook_craft_id] = facebook_craft._id.to_s
      web_crafts << facebook_craft
    end

    if webpage_craft_id.present?
      webpage_craft = WebpageCraft.find(webpage_craft_id) rescue nil
    else
      webpage_craft = WebpageService.web_craft_for_href(webpage_url) if webpage_exists?
    end
    if webpage_craft
      updated_ids[:webpage_craft_id] = webpage_craft._id.to_s
      web_crafts << webpage_craft
    end

    if web_crafts.empty?
      return nil 
    end

    # see if a craft is already bound to any of the web_crafts
    crafts_map = {}
    web_crafts.map{|wc| crafts_map[wc.craft._id] = wc.craft if wc.craft.present?} # collect all the parent crafts for the web_crafts
    crafts = crafts_map.values
    if 1<crafts.size  # ambiguos situation if more than one craft already exists
      puts "Now Confused: Multiple crafts  exists for this HoverCraft #{_id}:"
      crafts.each{|c| puts "CraftID: #{c._id}"}
      updated_ids[:error_duplicate_crafts] = true
      update_my_columns_(updated_ids) # skip callbacks to avoid infinite loop. update_columns not available till rails 4 
      return nil
    end
    
    craft = crafts.first if crafts.present?
    craft ||= Craft.create

    craft.bind(web_crafts)
    updated_ids[:craft_id] =craft._id

    HoverCraft.skip_callback(:save, :after, :trigger_craft_materialization) # skip the callback, avoid infinite loop on save
    update_attributes(updated_ids) # skip active_record callbacks    
    HoverCraft.set_callback(:save, :after, :trigger_craft_materialization)  # restore the callback for future calls
    craft
  end

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
    # = self.fit_score_food = self.fit_score_mobile =
    self.fit_score = self.fit_score_name = self.fit_score_username = self.fit_score_website = score
  end

  # after saving
  def trigger_craft_materialization
    materialize_craft if followed? and fit_score > FIT_neutral
  end

  # before saving
  def calculate_fit_scores
    # calculate matches strengths
    return set_all_fit_scores(FIT_duplicate_crafts) if error_duplicate_crafts
    return set_all_fit_scores(FIT_need_to_explore) if fit_score.eql? FIT_need_to_explore
    return set_all_fit_scores(FIT_zero) if skip_this_craft
    return set_all_fit_scores(FIT_missing_craft) if yelp_does_not_exist? or twitter_does_not_exist?

    # calculate_food_fit_score
    # calculate_mobile_fit_score
    # return set_all_fit_scores(FIT_absolute) if FIT_absolute.eql? fit_score_food and FIT_absolute.eql? fit_score_mobile

    calculate_website_fit_score
    calculate_name_fit_score
    calculate_username_fit_score

    return (self.fit_score = FIT_absolute) if FIT_absolute.eql? fit_score_website
    return (self.fit_score = FIT_absolute) if yelp_exists? and twitter_exists? and facebook_exists? and FIT_absolute.eql? fit_score_name
    return (self.fit_score = FIT_check_manually) if FIT_absolute.eql? fit_score_name
    return (self.fit_score = FIT_check_manually) if FIT_absolute.eql? fit_score_username
  end

  def calculate_website_fit_score 
    return (self.fit_score_website = FIT_check_manually) if yelp_website.blank? or twitter_website.blank?

    if Web.href_domains_match?(yelp_website, twitter_website)
      self.fit_score_website = FIT_absolute
      self.fit_score_website = FIT_check_manually if facebook_website.present? and not Web.href_domains_match?(yelp_website, facebook_website)
      return self.fit_score_website
    else # website domains do not match
      self.fit_score_website = FIT_zero
    end
  end

  def calculate_name_fit_score
    return (self.fit_score_name = FIT_check_manually) if yelp_name.blank? or twitter_name.blank?
      
    if names_match?(yelp_name, twitter_name)
      self.fit_score_name = FIT_absolute
      self.fit_score_name = FIT_check_manually if facebook_name.present? and not names_match?(yelp_name, facebook_name)
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

  # def calculate_food_fit_score 
  #   return (self.fit_score_food = FIT_absolute) if craft_is_for_food?
  #   self.fit_score_food = FIT_check_manually
  #   # check yelp categories?
  # end

  # def calculate_mobile_fit_score
  #   return (self.fit_score_mobile = FIT_absolute) if craft_is_mobile
  #   self.fit_score_mobile = FIT_check_manually
  # end

  def self.beam_up(url='www.food-truck.me', path='hover_crafts/sync.json', use_ssl=false, cookies = {}, port=nil)
    HoverCraft.all.each do |h|
      h.beam_up(url, path, use_ssl, cookies, port)
    end
  end

  def beam_up(url, path, use_ssl=false, cookies = {}, port=nil)
    params = { hover_craft: self.to_json }
    r = Web.http_post(url, path, params, use_ssl, cookies, port)
    puts r
    r
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
  # geocoding  aliases

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


  # def explore
  #   return unless fit_score.eql? FIT_need_to_explore
  #   explore_twitter_id if twitter_id.present?
  #   # +++ explore under other conditions??
  # end

  # def self.explore_missing_twitter_web_crafts
  #   rate_limit = TwitterService.rate_limit # see how many request we can make
  #   if rate_limit.zero?
  #     puts "Twitter Rate Limit Already Reached"
  #     puts "Try again in #{TwitterService.how_long_until_rate_limit_resets}"
  #     return 
  #   end

  #   crafts = Craft.without_twitter # find all crafts with missing twitter webcrafts
  #   puts "There are #{crafts.count} crafts where twitter is missing"
  #   hover_crafts = []
  #   crafts.each do |craft|
  #     next if craft.yelp.nil?
  #     h = HoverCraft.where(yelp_id: craft.yelp.yelp_id).first 
  #     hover_crafts<<h if (h.present? and h.twitter_exists?)
  #   end
  #   puts "There are #{hover_crafts.count} crafts where a twitter_craft could be explored"
  #   hover_crafts[0..(rate_limit-1)].each do |h|
  #     h.materialize_craft
  #   end
  #   puts "Done"
  #   crafts = Craft.all.reject{|c| c.twitter.present?} # find all crafts with missing twitter webcrafts
  #   puts "Now there are #{crafts.count} crafts where twitter is missing"    
  # end

  # def explore_twitter_id(remaining_hits=nil)
  #   return false unless twitter_id.present?

  #   update_attributes(fit_score: FIT_zero) # assume there is no fit

  #   num_hits_left = remaining_hits || Twitter.rate_limit_status.remaining_hits
  #   return false if num_hits_left.zero?


  #   twitter_user = TwitterService.user_for_id(twitter_id)

  #   return false unless twitter_user.present?

  #   website = twitter_user['url']
  #   return false unless website.present?

  #   screen_name = twitter_user['screen_name']
  #   description = twitter_user['description'].downcase if twitter_user['description'].present?

  #   doc = Web.hpricot_doc(website)
  #   if doc.present?
  #     facebook_links  = ::FacebookService.hrefs_in_hpricot_doc(doc)
  #     yelp_links      = ::YelpService.hrefs_in_hpricot_doc(doc)
  #     # hrefs[:you_tube]    = YouTubeService.hrefs_in_hpricot_doc(doc) unless hrefs[:you_tube].present?
  #     # hrefs[:flickr]    = FlickrService.hrefs_in_hpricot_doc(doc) unless hrefs[:flickr].present?
  #     # hrefs[:rss]       = RssService.hrefs_in_hpricot_doc(doc) unless hrefs[:rss].present?
  #   end
  #   twitter_hover_craft = TwitterService.hover_craft(screen_name)
  #   facebook_hover_craft = FacebookService.hover_craft(facebook_links.first) if facebook_links.present?
  #   yelp_hover_craft = YelpService.hover_craft(yelp_links.first) if yelp_links.present?
  #   twitter_hover_craft ||= {}
  #   facebook_hover_craft ||= {}
  #   yelp_hover_craft ||= {}
  #   dup = HoverCraft.where(twitter_username: twitter_username).first
  #   return true if dup.present?
  #   dup = HoverCraft.where(yelp_username: twitter_username).first
  #   return true if dup.present?

  #   udpate_attributes(yelp_hover_craft.merge(twitter_hover_craft).merge(facebook_hover_craft))
  #   # identify most likely facebook link if there is more than 1
  #   # create HoverCraft if strong fit or if description['truck'] or yelp_hover_craft.present?
  # rescue Exception => e
  #   puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
  #   puts e.message
  #   puts "When exploring hover craft"
  #   puts e.backtrace
  #   puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"        
  #   false
  # end

  # def self.explore_yelp_listing(biz)
  #   return unless biz.present?

  #   dup = HoverCraft.where(yelp_id: biz['id']).first
  #   return if dup.present?

  #   yelp_hover_craft = YelpService.hover_craft(biz)
  #   puts "got yelp_hover_craft #{yelp_hover_craft}"
  #   return unless yelp_hover_craft.present?
  #   puts "yelp_hover_craft[:yelp_website]: #{yelp_hover_craft[:yelp_website]}"
  #   if yelp_hover_craft[:yelp_website].present?
  #     doc = Web.hpricot_doc(yelp_hover_craft[:yelp_website])
  #     if doc.present?
  #       puts "got hpricot doc for #{yelp_hover_craft[:yelp_website]}"
  #       twitter_links   = ::TwitterService.hrefs_in_hpricot_doc(doc)
  #       facebook_links  = ::FacebookService.hrefs_in_hpricot_doc(doc)
  #       # hrefs[:yelp]      = ::YelpService.hrefs_in_hpricot_doc(doc) unless hrefs[:yelp].present?
  #       # hrefs[:you_tube]    = YouTubeService.hrefs_in_hpricot_doc(doc) unless hrefs[:you_tube].present?
  #       # hrefs[:flickr]    = FlickrService.hrefs_in_hpricot_doc(doc) unless hrefs[:flickr].present?
  #       # hrefs[:rss]       = RssService.hrefs_in_hpricot_doc(doc) unless hrefs[:rss].present?
  #     end
  #   end
  #   twitter_hover_craft = TwitterService.hover_craft(twitter_links.first) if twitter_links.present?
  #   facebook_hover_craft = FacebookService.hover_craft(facebook_links.first) if facebook_links.present?
  #   twitter_hover_craft ||= {}
  #   facebook_hover_craft ||= {}
  #   h = HoverCraft.create(yelp_hover_craft.merge(twitter_hover_craft).merge(facebook_hover_craft))
  #   puts "---------"
  #   # identify most likely twitter link if there is more than 1
  #   # identify most likely facebook link if there is more than 1
  #   # create HoverCraft if strong fit
  #   h
  # rescue Exception => e
  #   puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
  #   puts e.message
  #   puts "When exploring hover craft"
  #   puts e.backtrace
  #   puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"        
  # end


  # def self.scan_for_food_trucks_near_place(place, state, term="food truck, truck", page=1, total_pages=0)
  #   return if ( 1<page and (total_pages < page or 5000 < (page*YelpService::V2_MAX_RESULTS_LIMIT) ) )

  #   results = YelpService.food_trucks_near_place(place, state, term, page)
  #   return unless results.present?

  #   results ||= {}
  #   if 1 == page
  #     total_results = results['total'] || 0
  #     total_pages = 1 + (total_results / YelpService::V2_MAX_RESULTS_LIMIT)
  #     puts "total_results = #{total_results}"
  #     puts "total_pages = #{total_pages}"
  #   end

  #   biz_list = *results['businesses']
  #   if biz_list.count.zero?
  #     puts "==========================================="
  #     puts "Zero results returned! From page #{page} of #{total_pages}"
  #     puts "==========================================="
  #     return 
  #   end
  #   puts "============================"
  #   puts "exploring #{biz_list.count} results from page #{page} of #{total_pages}"
  #   biz_list.each{ |biz| explore_yelp_listing(biz) }

  #   scan_for_food_trucks_near_place(place, state, term, page+1, total_pages)
  # end
