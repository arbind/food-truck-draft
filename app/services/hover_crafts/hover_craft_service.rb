class HoverCraftService
  include Singleton  


  # materializers
  def materialize_from_twitter_account
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

    yelp_info = yelp_info(biz)
    puts "got yelp_info #{yelp_info}"
    return nil unless yelp_info.present?
    puts "yelp_info[:yelp_website]: #{yelp_info[:yelp_website]}"
    if yelp_info[:yelp_website].present?
      # +++ ---> check if website is twitter or facebook
      doc = Web.hpricot_doc(yelp_info[:yelp_website])
      if doc.present?
        puts "got hpricot doc for #{yelp_info[:yelp_website]}"
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
    h = HoverCraft.create(defaults.merge(yelp_info).merge(twitter_info).merge(facebook_info))
    puts h
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
  def scan_place_for_food_trucks(place)
    scan_place('food truck, truck', place)
  end

  def scan_place_for_food(place)
    # scan_place('food', place)
    # scan_place('restaurant', place)
    # scan_place('dinner', place)
    # scan_place('lunch', place)
    # scan_place('breakfast', place)
  end

  def scan_place_for_cuisine(cuisine, place)
    scan_place(cuisine, place)
  end

  def scan_place(term, place)
    scan_place_on_yelp(term, place)
    # +++ add other data sources
  end

  def scan_place_on_yelp(term, place, page=1, total_pages=0)
    return if ( 1<page and (total_pages < page or 5000 < (page*YelpService::V2_MAX_RESULTS_LIMIT) ) )
    location = place.downcase

    defaults = { address: location }

    results = YelpService.search(term, location, page)
    return unless results.present?

    results ||= {}
    if 1 == page
      total_results = results['total'] || 0
      total_pages = 1 + (total_results / YelpService::V2_MAX_RESULTS_LIMIT)
      puts "total_results = #{total_results}"
      puts "total_pages = #{total_pages}"
    end

    biz_list = *results['businesses']
    if biz_list.count.zero?
      puts "==========================================="
      puts "Zero results returned! From page #{page} of #{total_pages}"
      puts "==========================================="
      return 
    end
    puts "============================"
    puts "exploring #{biz_list.count} results from page #{page} of #{total_pages}"
    # biz_list.each{ |biz| materialize_from_yelp_biz(biz, defaults) }
    materialize_from_yelp_biz(biz_list.first, defaults)

    # scan_place_on_yelp(term, location, state, country, page+1, total_pages)
  end


  def fill_twitter_info(hover_craft, username)
    return true if hover_craft.twitter_username.present?
    # +++ todo!
    twitter_info = nil # +++
    return false if twitter_info.nil?
    hover_craft.update_attributes(twitter_info)
  end

  def fill_facebook_info(hover_craft, fb_username)
    return true if hover_craft.facebook_username.present?
    # +++ todo!
    facebook_info = nil # +++
    return false if facebook_info.nil?
    hover_craft.update_attributes(facebook_info)
  end

  def fill_website_info(hover_craft)
    return true if hover_craft.website.present?
    # +++ todo!
    # analyze yelp, twitter and fb website urls for a best match that is not a provider
    website_info = nil # +++
    return false if website_info.nil?
    hover_craft.update_attributes(website_info)
  end

  def fill_yelp_info(hover_craft)
    return true if hover_craft.yelp_id.present?

    place = hover_craft.address
    return false if place.nil?

    name = hover_craft.twitter_name || hover_craft.facebook_name
    return false if name.nil?

    name.downcase!
    yelp_info = yelp_info_for_name_in_place(name, place)
    return false if yelp_info.nil?
    hover_craft.update_attributes(yelp_info)
  end



private
  def facebook_info(facebook_username_or_url)
    username = Web.service_id_from_string_or_href(facebook_username_or_url, :facebook);
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

    hover_craft = {
      facebook_id: id,
      facebook_name: name,
      facebook_username: username,
      facebook_href: href,
      facebook_website: website,
    }
  end

  def twitter_info(twitter_screen_name_or_url)
    #scrape from web page (does not use api) 
    username = Web.service_id_from_string_or_href(twitter_screen_name_or_url, :twitter);
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

    hover_craft = {
      twitter_name: name,
      twitter_username: screen_name || username,
      twitter_href: href,
      twitter_website: website,
      twitter_following_list: nil
    }
  end

  def yelp_info_for_name_in_place(name, place)
    results = YelpService.search(name, place)
    return nil unless results.present?

    biz_list = *results['businesses']
    return nil if results.empty?

    biz = biz_list.first
    yelp_info(biz)
  end

  def yelp_info(biz)
    return nil unless biz.present? and biz['id'].present?

    yelp_id = biz['id']
    name= biz['name']
    href = biz['url']
puts "----"
puts biz
puts "----"
    website = YelpService.website_for_account(yelp_id)
    puts "website: #{website}"
    if website
      begin
        u = URI.parse(website)
        u = URI.parse("http://#{website}") unless u.host.present?
        website = nil if u.host.nil? or 'yelp.com'.eql? u.host
      rescue
      end
    end

    hover_craft = {
      yelp_id: yelp_id,
      yelp_name: name,
      yelp_href: href,
      yelp_website: website
    }
  end


end
