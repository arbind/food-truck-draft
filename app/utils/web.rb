class Web

  def self.as_href(url_like)
    u = URI.parse(url_like.to_s.downcase)
    u = URI.parse("http://#{url_like.to_s.downcase}") if u.host.nil?
    u.to_s
  end

  def self.http_get(host, path='/', params = {}, use_ssl = false, cookies = {}, port=nil)
    # data_payload = Rack::Utils.escape(data)
    href = href_for(host, path, params, use_ssl, port)
    # +++ TODO cookies (session) see: http://dzone.com/snippets/custom-httphttps-getpost
    HTTParty.get(href)
  end

  def self.href_for(host, path='/', params = {}, use_ssl = false, port=nil)
    url = url_for(host, path, params, use_ssl, port)
    return '' if url.nil?
    url.to_s
  end

  def self.url_for(host, path='/', params = {}, use_ssl = false, port=nil)
    url_port = port || (use_ssl ? 443: 80)
    protocol = use_ssl ? 'https' : 'http'
    if path.match(/^\//) # see if path starts with a /
      url_path = path 
    else
      url_path = "/" << path 
    end
    href = "#{protocol}://#{host}:#{url_port}#{url_path}"
    url = Addressable::URI.parse(href)
    return nil if url.nil?
    url.query_values ||= {}
    url.query_values = url.query_values.merge(params) 
    url
  end

  def self.image_exists?(url)
    image_is_there = false
    begin
      url = URI.parse(url)
      Net::HTTP.start(url.host, url.port) do |http|
      h = http.head(url.request_uri)
        image_is_there = (h.code == "200") ? h['Content-Type'].start_with?('image') : false
      end
    rescue Exception => e
      # bad url
    end
    image_is_there
  end

  def self.domain_for_href(href)
    link = href.to_s.downcase
    u = URI.parse(link)
    u = URI.parse("http://#{link}") if u.host.nil?
    u.host
  end

  def self.href_domains_match?(url1, url2)
    return false unless url1.present?
    return false unless url2.present?
    domain1 = domain_for_href(url1)
    matches = domain1.match /(^www\.|^)(.*)$/
    return false if matches.nil? or matches.size < 3
    domain1 = matches[2]

    domain2 = domain_for_href(url2)
    matches = domain2.match /(^www\.|^)(.*)$/
    return false if matches.nil? or matches.size < 3
    domain2 = matches[2]

    domain1.eql? domain2
  end
  def self.values_match?(value1, value2)
    return true if value1.eql? value2
    return false unless (value1.present? and value2.present?)
    val1 = value1.downcase.gsub(/\s+/, '')
    val2 = value2.downcase.gsub(/\s+/, '')
    val1.eql? val2
  end

  def self.service_id_from_string_or_href(id_or_url, service, path="")
    # Assumes that the id is at the end of a url
    # usage:
    # Web.service_id_from_string_or_href('http://www.facebook.com/arb', :facebook) -> arb
    # Web.service_id_from_string_or_href('https://yelp.com/biz/arb', :yelp, 'biz') -> arb
    # Web.service_id_from_string_or_href('arb', :yelp, 'biz') -> arb
    return nil unless id_or_url.present?
    return nil unless service.present?
    svc = service.to_s.downcase
    p = path
    p << '/' if p.present? and '/' != p[-1]
    # match the last token of a service url, or else the entire string itself
    matches = (id_or_url.match /((^https?:\/\/www\.|^https?:\/\/)#{svc}\.com\/#{p.present? ? p : ""}|^)(\S*)/)
    return nil if matches.nil? or matches.size < 4
    user_id = matches[3]
    return nil unless user_id.present?
    return nil if user_id.match /^https?:/ #make sure the matched user id is not a url (didn't match on the service)
    user_id.slice!(0) if ('twitter' == svc and '@' == user_id[0]) # @twitter_handles
    user_id
  end


  def self.hpricot_doc(url) doc = open(url, 'User-Agent' => 'ruby') { |f| Hpricot(f) } end

  # find social handles on a web page (try the home page)
  # def self.social_pages_for_website(url)
  #   doc = hpricot_doc(url)
  #   {
  #     twitter_pages:  twitter_pages_for_hpricot_doc(doc),
  #     facebook_pages: facebook_pages_for_hpricot_doc(doc),
  #     flicker_pages: facebook_pages_for_hpricot_doc(doc),
  #     yelp_listings: yelp_listings_for_hpricot_doc(doc),
  #     rss_feeds: rss_feeds_for_hpricot_doc(doc)
  #   }
  # end

  def self.web_crafts_for_website(url, look_for={}) # i.e.: look_for = {name: 'truck'}
    u = URI.parse(url.to_s.downcase)
    u = URI.parse("http://#{url.to_s.downcase}") if u.host.nil?
    return nil if u.host.nil?
    web_service = u.host.split('.')[-2].symbolize # e.g. :facebook or :twitter or :yelp or webpage domain or other

    website = nil
    service = web_service
    begin
      svc_class_name = web_service.to_s.capitalize + "Service" # e.g. "FacebookService" or TwitterService" or "YelpService" or other
      svc_class = Kernel.const_get(svc_class_name.to_sym)
      # class was found for service e.g. "FacebookService" or TwitterService" or "YelpService" or other
      website = svc_class.website_for_account(url)
    rescue
      service = :webpage # assume this is a webpage if no other service is found
      website = url
      # class was not found for service e.g. "GrillEmAllService"
    end
    hrefs = {}
    hrefs[service] = [ url ]

    if website.present?
      doc = hpricot_doc(website)
      hrefs[:twitter]   = ::TwitterService.hrefs_in_hpricot_doc(doc) unless hrefs[:twitter].present?
      hrefs[:facebook]  = ::FacebookService.hrefs_in_hpricot_doc(doc) unless hrefs[:facebook].present?
      hrefs[:yelp]      = ::YelpService.hrefs_in_hpricot_doc(doc) unless hrefs[:yelp].present?
      # hrefs[:you_tube]    = YouTubeService.hrefs_in_hpricot_doc(doc) unless hrefs[:you_tube].present?
      # hrefs[:flickr]    = FlickrService.hrefs_in_hpricot_doc(doc) unless hrefs[:flickr].present?
      # hrefs[:rss]       = RssService.hrefs_in_hpricot_doc(doc) unless hrefs[:rss].present?
    end
puts hrefs
    web_crafts_map = {} # assume the first href found on a site is the primary url
    web_crafts_map[:web_crafts] = [] # an array stores all the WebCrafts

    hrefs.each do |service, hrefs|
      href = hrefs.shift
      web_crafts_map[service] = {}
      web_crafts_map[service][:href] = href
      web_crafts_map[service][:other_hrefs] = hrefs

      svc_class_name = service.to_s.capitalize + "Service" # e.g. "TwitterService"
      begin
        svc_class = Kernel.const_get(svc_class_name.to_sym)
puts "web_craft = #{svc_class}.web_craft_for_href(#{href})"
        web_craft = svc_class.web_craft_for_href(href)
        if (web_craft)
          web_crafts_map[:web_crafts] << web_craft
          web_crafts_map[service][:web_craft] = web_craft
        end
      rescue Exception => e
        puts e.message
        puts e
      end
    end

    yelp = web_crafts_map[:yelp][:web_craft]
    puts "yelp = #{yelp}"
    twitter = web_crafts_map[:twitter][:web_craft]
    puts "twitter = #{twitter}"
    fb = web_crafts_map[:facebook][:web_craft]
    puts "fb = #{fb}"
    web_crafts_map[:match] = {}

    # calculate matches strengths
    strength = :zero if yelp.nil? or twitter.nil?
    strength ||= :high if yelp and twitter and href_domains_match?(yelp.website, twitter.website)
    strength ||= :medium if yelp and twitter and values_match?(yelp.name, twitter.name)
    strength ||= :low
    web_crafts_map[:match][:yelp_twitter_match] = strength

    strength = :zero if yelp.nil? or fb.nil?
    strength ||= :high if yelp.nil? and fb.nil? and href_domains_match?(yelp.website, fb.website)
    strength ||= :medium if yelp.nil? and fb.nil? and values_match?(yelp.name, fb.name)
    strength ||= :low
    web_crafts_map[:match][:yelp_facebook_match] ||= strength

    strength = :zero if twitter.nil? or fb.nil?
    strength ||= :high if twitter and fb and href_domains_match?(twitter.website, fb.website)
    strength ||= :medium if twitter and fb and values_match?(twitter.name, fb.name)
    strength ||= :low
    web_crafts_map[:match][:twitter_facebook_match] ||= strength

    if look_for.present?    
      look_for.each do |keyword, field_names|
        web_crafts_map[:match][keyword.symbolize] ||= {}
        fields = *field_names
        if yelp 
          found = false
          fields.each { |field| found ||= (""<<yelp[field].to_s).downcase.include?(keyword.downcase) }
          web_crafts_map[:match][keyword.symbolize][:yelp] = found
        end
        if twitter 
          found = false
          fields.each { |field| found ||= (""<<twitter[field].to_s).downcase.include?(keyword.downcase) }
          web_crafts_map[:match][keyword.symbolize][:twitter] = found
        end
        if fb 
          found = false
          fields.each { |field| found ||= (""<<fb[field].to_s).downcase.include?(keyword.downcase) }
          web_crafts_map[:match][keyword.symbolize][:facebook] = found
        end
      end
    end
# puts web_crafts_map
    web_crafts_map
  end




  def self.hrefs_in_hpricot_doc(doc, text_found_in_href, href_atts = [ 'href' ])
    attributes_in_hpricot_doc(doc, text_found_in_href, href_atts)
  end

  def self.attributes_in_hpricot_doc(doc, text_found_in_href, href_att)
    return nil unless ( doc.present? and text_found_in_href.present? and href_att.present? )
    href_list = []
    href_atts = *href_att
    href_atts.each do |att|
      # search all elements where att contains text_found_in_href: e.g. <a href="www.twitter.com/awesome_one">...</a>
      element_list = doc.search("[@#{att}*=#{text_found_in_href}]") #
      if element_list.present?
        values = element_list.map{ |e| e["#{att}"]} 
        href_list += values if values.present?
      end
    end
    href_map = {}
    unique_hrefs= []
    href_list.each do |href|
      next if href_map[href.downcase]
      href_map[href.downcase] = true
      unique_hrefs << href # save href, preserving order, and filtering out duplicates
    end
    unique_hrefs
  end

end