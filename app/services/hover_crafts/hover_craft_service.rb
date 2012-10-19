class HoverCraftService
  include Singleton

  def delete_all_the_crafts_and_job_queue_and_clear_hover_craft_all_ids(ok='no')
    return unless ok.eql? :oK
    puts "Deleted #{Craft.all.delete} Crafts"
    puts "Deleted #{WebCraft.all.delete} WebCrafts"
    puts "Deleted #{JobQueue.all.delete} JobQueue"
    count = 0
    HoverCraft.all.each do |hc|
      count = count + 1 
      updates = {
        craft_id: nil,
        tweet_stream_id: nil,
        yelp_craft_id: nil,
        twitter_craft_id: nil,
        facebook_craft_id: nil,
        webpage_craft_id: nil
      }
      hc.update_attributes(updates)
    end
    puts "Cleared id's for #{count} HoverCrafts"
  end

  # materializers
  def materialize_from_craft(craft)
    # precondition: craft has at least 1 webcraft which is either a twitter or yelp webcraft
    return nil unless craft.present?
    return nil unless (craft.yelp.present? or craft.twitter.present?)

    # find existing hover craft
    hover_craft ||= HoverCraft.where(craft_id:    craft._id.to_s).first
    hover_craft ||= HoverCraft.where(twitter_id:  craft.twitter.twitter_id).first if craft.twitter.present?
    hover_craft ||= HoverCraft.where(twitter_username:  craft.twitter.username).first if craft.twitter.present?
    hover_craft ||= HoverCraft.where(yelp_id:     craft.yelp.yelp_id).first if craft.yelp.present?
    hover_craft ||= HoverCraft.where(facebook_id: craft.facebook.facebook_id).first if craft.facebook.present?
    hover_craft ||= HoverCraft.where(webpage_url: craft.webpage.url).first if craft.webpage.present?

    hover_craft_info = info_from_craft(craft)

    if hover_craft_info[:yelp_id].nil? # grab info from yelp
      begin
        place = hover_craft_info[:address]
        name = hover_craft_info[:twitter_name] || hover_craft_info[:facebook_name]
        name.downcase!
        yelp_info = yelp_info_for_name_in_place(name, place)
        hover_craft_info.merge!(yelp_info)
        hover_craft ||= HoverCraft.where(yelp_name: hover_craft_info[:yelp_name]).first if hover_craft_info[:yelp_name].present?
      rescue
      end
    end

    if hover_craft_info[:webpage_url].nil?
      url = determine_best_website(hover_craft_info)
      hover_craft_info[:webpage_url] = url
      hover_craft ||= HoverCraft.where(webpage_url: url).first if hover_craft_info[:webpage_url].present?
    end

    # create hover craft if none have been found yet
    hover_craft ||= HoverCraft.create(craft_id: craft._id.to_s)

    hover_craft.update_attributes(hover_craft_info)

    scraped_info = scrape_webpage_for_info(hover_craft)
    hover_craft.update_attributes(scraped_info) if scraped_info.present?
    hover_craft
  end

  # when rate limit reached for yelp service, sometimes the yelpcraft does not get materialized
  # run this the next day to pick them back up
  def bind_missing_yelp_crafts(hover_crafts=nil)
    h_crafts = hover_crafts
    h_crafts ||= HoverCraft.missing_yelp_craft
    h_crafts.each do |hc|
      next if hc.yelp_craft_id.present?
      next unless hc.craft_id.present? and hc.twitter_craft.present? and hc.yelp_id.present? and hc.yelp_href.present? and not hc.skip_this_craft
      next unless names_match?(hc.yelp_name, hc.twitter_name)

      craft = Craft.find(hc.craft_id) rescue nil
      next unless craft.present?

      yelp_craft = YelpService.web_craft_for_href(yelp_href) rescue nil
      break unless help_craft.present?
      craft.bind(yelp_craft)
    end
  end

  def scrape_webpage_for_info(hover_craft)
    return nil if hover_craft.fully_populated?
    return nil if hover_craft.webpage_url.nil?

    # crawl it to fill in any missing infor
    doc = Web.hpricot_doc(hover_craft.webpage_url)
    return false if doc.nil?

    info ={}

    # try to find links to providers if they are missing in the hover_craft
    yelp_links          = YelpService.hrefs_in_hpricot_doc(doc) if hover_craft.yelp_id.nil?
    twitter_links       = TwitterService.hrefs_in_hpricot_doc(doc) if hover_craft.twitter_username.nil?
    facebook_links      = FacebookService.hrefs_in_hpricot_doc(doc) if hover_craft.facebook_username.nil?
    # hrefs[:you_tube]  = YouTubeService.hrefs_in_hpricot_doc(doc) unless hrefs[:you_tube].present?
    # hrefs[:flickr]    = FlickrService.hrefs_in_hpricot_doc(doc) unless hrefs[:flickr].present?
    # hrefs[:rss]       = RssService.hrefs_in_hpricot_doc(doc) unless hrefs[:rss].present?

    # merge in reverse priority order
    info.merge!(facebook_info_from_href(facebook_links.first)) if facebook_links.present?
    info.merge!(twitter_info_from_href(twitter_links.first)) if twitter_links.present?
    info.merge!(yelp_info_from_href(yelp_links.first)) if yelp_links.present?
    info
  end

  # def materialize_from_twitter_craft(twitter_craft)
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
  #   twitter_info = TwitterService.hover_craft(screen_name)
  #   facebook_info = FacebookService.hover_craft(facebook_links.first) if facebook_links.present?
  #   yelp_info = YelpService.hover_craft(yelp_links.first) if yelp_links.present?
  #   twitter_info ||= {}
  #   facebook_info ||= {}
  #   yelp_info ||= {}
  #   dup = HoverCraft.where(twitter_username: twitter_username).first
  #   return true if dup.present?
  #   dup = HoverCraft.where(yelp_username: twitter_username).first
  #   return true if dup.present?

  #   udpate_attributes(yelp_info.merge(twitter_info).merge(facebook_info))
  #   # identify most likely facebook link if there is more than 1
  #   # create HoverCraft if strong fit or if description['truck'] or yelp_info.present?
  # rescue Exception => e
  #   puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
  #   puts e.message
  #   puts "When exploring hover craft"
  #   puts e.backtrace
  #   puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"        
  #   false
  # end

  def materialize_from_yelp_url
  end

  def materialize_from_yelp_biz(biz, defaults={})
    return unless biz.present?

    dup = HoverCraft.where(yelp_id: biz['id']).first
    return dup if dup.present?

    yelp_info = yelp_info_for_biz(biz)
    return nil unless yelp_info.present?
    if yelp_info[:yelp_website].present?
      # +++ ---> check if website is twitter or facebook
      doc = Web.hpricot_doc(yelp_info[:yelp_website])
      if doc.present?
        twitter_links   = ::TwitterService.hrefs_in_hpricot_doc(doc)
        facebook_links  = ::FacebookService.hrefs_in_hpricot_doc(doc)
        # hrefs[:yelp]      = ::YelpService.hrefs_in_hpricot_doc(doc) unless hrefs[:yelp].present?
        # hrefs[:you_tube]    = YouTubeService.hrefs_in_hpricot_doc(doc) unless hrefs[:you_tube].present?
        # hrefs[:flickr]    = FlickrService.hrefs_in_hpricot_doc(doc) unless hrefs[:flickr].present?
        # hrefs[:rss]       = RssService.hrefs_in_hpricot_doc(doc) unless hrefs[:rss].present?
      end
    end
    twitter_info = twitter_info(twitter_links.first) if twitter_links.present?
    facebook_info = facebook_info(facebook_links.first) if facebook_links.present?
    twitter_info ||= {}
    facebook_info ||= {}
    # check and bind twitter_craft if it already exists, fb too (before save?)
    # bind craft id also if found (priority to twitter)
    # bind tweet stream id too if twitter craft was found
    h = HoverCraft.create(defaults.merge(yelp_info).merge(twitter_info).merge(facebook_info))
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
    nil
  end


  # scanners
  def scan_place_for_food_trucks(place, page=1, total_pages=0)
    scan_place('food truck, truck', place, page, total_pages)
  end

  def scan_place_for_food(place, page=1, total_pages=0)
    # scan_place('food', place, page, total_pages)
    # scan_place('restaurant', place, page, total_pages)
    # scan_place('dinner', place, page, total_pages)
    # scan_place('lunch', place, page, total_pages)
    # scan_place('breakfast', place, page, total_pages)
  end

  def scan_place_for_cuisine(cuisine, place, page=1, total_pages=0)
    scan_place(cuisine, place, page, total_pages)
  end

  def scan_place(term, place, page=1, total_pages=0)
    scan_place_on_yelp(term, place, page, total_pages)
    # +++ add other data sources
  end

  def scan_place_on_yelp(term, place, page=1, total_pages=0)
    return if ( 1<page and (total_pages < page or 5000 < (page*YelpService::V2_MAX_RESULTS_LIMIT) ) )
    max_pages = total_pages
    defaults = { address: place.downcase }

    results = YelpService.search(term, place, page)
    return unless results.present?

    results ||= {}
    if 1 == page and max_pages.zero?
      total_results = results['total'] || 0
      max_pages = 1 + (total_results / YelpService::V2_MAX_RESULTS_LIMIT)
    end

    biz_list = *results['businesses']
    if biz_list.count.zero?
      puts "==========================================="
      puts "Zero results returned! From page #{page} of #{max_pages}"
      puts "==========================================="
      return 
    end
    puts "============================"
    puts "exploring #{biz_list.count} results from page #{page} of #{max_pages}"
    biz_list.each{ |biz| materialize_from_yelp_biz(biz, defaults) }

    scan_place_on_yelp(term, place, page+1, max_pages)
  end

private

  def determine_best_website(hover_craft_info)
    return hover_craft_info[:webpage_url] if hover_craft_info[:webpage_url].present?
    if :webpage.eql? Web.provider_for_href(hover_craft_info[:yelp_website])
      return hover_craft_info[:yelp_website] if Web.href_domains_match?(hover_craft_info[:yelp_website], hover_craft_info[:twitter_website])
      return hover_craft_info[:yelp_website] if Web.href_domains_match?(hover_craft_info[:yelp_website], hover_craft_info[:facebook_website])
    end
    if :webpage.eql? Web.provider_for_href(hover_craft_info[:twitter_website])
      return hover_craft_info[:twitter_website] if Web.href_domains_match?(hover_craft_info[:twitter_website], hover_craft_info[:facebook_website])
    end
    return hover_craft_info[:twitter_website] if hover_craft_info[:twitter_website].present? and :webpage.eql? Web.provider_for_href(hover_craft_info[:twitter_website])
    return hover_craft_info[:yelp_website] if hover_craft_info[:yelp_website].present? and :webpage.eql? Web.provider_for_href(hover_craft_info[:yelp_website])
    return hover_craft_info[:facebook_website] if hover_craft_info[:facebook_website].present? and :webpage.eql? Web.provider_for_href(hover_craft_info[:facebook_website])
    nil
  end

  def info_from_craft(craft)
    return nil unless craft.present? and craft.web_crafts.present?
    # pick off most likely address
    address   = craft.yelp.address if craft.yelp.present?
    address ||= craft.twitter.address if craft.twitter.present?
    address ||= craft.facebook.address if craft.facebook.present?

    info = {}
    info[:craft_id] = craft._id.to_s 
    info[:address] = address
    info[:tweet_stream_id] = craft.tweet_stream_id
    info.merge!(info_from_web_craft(craft.twitter))  if craft.twitter.present?
    info.merge!(info_from_web_craft(craft.yelp))     if craft.yelp.present?
    info.merge!(info_from_web_craft(craft.facebook)) if craft.facebook.present?
    info.merge!(info_from_web_craft(craft.webpage))  if craft.webpage.present?
    info
  end

  def info_from_web_craft(web_craft)
    return nil unless web_craft.present?
    provider = web_craft.provider
    if :webpage.eql? provider
      info = {
        webpage_craft_id: web_craft._id.to_s,
        webpage_url: web_craft.url
      }
      return info
    end 

    info = {
      :"#{provider}_craft_id" => web_craft._id.to_s,
      :"#{provider}_id"       => web_craft.web_craft_id,
      :"#{provider}_name"     => web_craft.name,
      :"#{provider}_username" => web_craft.username,
      :"#{provider}_href"     => web_craft.href,
      :"#{provider}_website"  => web_craft.website
    }
  end

  def facebook_info_from_href(href)
    username = FacebookService.id_from_href(href);
    return nil unless username.present?
    web_craft_hash = FacebookService.web_fetch(username)
    return nil unless web_craft_hash.present?
    id = web_craft_hash['id']
    name = web_craft_hash['name']
    username = web_craft_hash['username']
    href = web_craft_hash['link']
    website = web_craft_hash['website']
    if website
      # +++ -> check if provider is twitter or facebook instead of website
      begin
        u = URI.parse(website)
        u = URI.parse("http://#{website}") unless u.host.present?
        website = nil if u.host.nil? or 'facebook.com'.eql? u.host
      rescue
      end
    end

    info = {
      facebook_id: id,
      facebook_name: name,
      facebook_username: username,
      facebook_href: href,
      facebook_website: website,
    }
  end

  def twitter_info_from_href(href)
    #scrape from web page (does not use api) 
    username = TwitterService.id_from_href(href);
    return nil unless username.present?

    username.downcase!
    href = "https://twitter.com/#{username}"
    doc = doc = Web.hpricot_doc(href)
    return nil unless doc.present?

    name = doc.search('h1 .fullname').text().squish
    screen_name = doc.search('.screen-name').text().squish.downcase
    screen_name.slice!(0) # slice off the @ in front of the screen name

    # validate webpage url
    website = doc.search('.url a[@href]').text().squish.downcase
    if website
      begin
        u = URI.parse(website)
        u = URI.parse("http://#{website}") unless u.host.present?
        website = nil if u.host.nil? or 'twitter.com'.eql? u.host
      rescue
      end
    end

    info = {
      twitter_name: name,
      twitter_username: screen_name || username,
      twitter_href: href,
      twitter_website: website,
    }
  end

  def yelp_info_from_href(href)
    yelp_id = YelpService.id_from_href(href);
    return nil unless yelp_id.present?
    biz = YelpService.biz_for_id(yelp_id)
    info = yelp_info_for_biz(biz)
  end

  def yelp_info_for_name_in_place(name, place)
    results = YelpService.search(name, place)
    return nil unless results.present?

    biz_list = *results['businesses']
    return nil if results.empty?

    biz = biz_list.first
    yelp_info_for_biz(biz)
  end

  def yelp_info_for_biz(biz)
    return nil unless biz.present? and biz['id'].present?

    yelp_id = biz['id']
    name= biz['name']
    href = biz['url']
    website = YelpService.website_for_account(yelp_id)
    if website
      begin
        u = URI.parse(website)
        u = URI.parse("http://#{website}") unless u.host.present?
        website = nil if u.host.nil? or 'yelp.com'.eql? u.host
      rescue
      end
    end

    info = {
      yelp_id: yelp_id,
      yelp_name: name,
      yelp_href: href,
      yelp_website: website
    }
  end

end
