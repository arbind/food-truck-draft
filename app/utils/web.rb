class Web

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

  def self.hpricot_doc(url) doc = open(url) { |f| Hpricot(f) } end

  # find social handles on a web page (try the home page)
  def self.social_pages_for_website(url)
    {
      twitter_pages:  twitter_pages_for_website(url),
      facebook_pages: facebook_pages_for_website(url)
    }
  end

  # twitter finder
  def self.twitter_pages_for_website(url)
    doc = hpricot_doc(url)
    return nil if doc.nil?
    tw_href_elements = doc.search("[@href*=twitter.com]")
    tw_href_elements = tw_href_elements.map{ |e| e['href']} if tw_href_elements.present?

    tw_elements = []
    tw_elements += tw_href_elements if tw_href_elements.present?
    tw_elements

    # +++ TODO:
    # grab username from the href
    # handle multiple links
    # look for like button or other references if first ref does not produce result
  end

  def self.username_from_twitter_page_url(twitter_page_url)
    return nil if twitter_page_url.nil?

    username = nil
    begin
      u = URI.parse(twitter_page_url.downcase)
      u = URI.parse("http://#{twitter_page_url.downcase}") if u.host.nil?
      return nil unless ['www.twitter.com', 'twitter.com'].include?(u.host)
      flat = twitter_page_url.downcase.gsub(/\/\//, '')
      tokens = flat.split('/')
      return nil unless tokens.present?

      case tokens.size
        when 2
          username = tokens[1] if twitter_username_is_valid?(tokens[1])
        when 3
          username = tokens[2] if ("#!" == tokens[1] and twitter_username_is_valid?(tokens[2]) )
        else
          # username = nil
      end
    rescue Exception => e
      puts e.message
      # return nil
    end
    username
  end

  def self.twitter_username_is_valid?(username)
    return false if username.nil?
    username_match = username.match /[A-Za-z0-9_]+/ 
    username_match.present? and username_match.to_s == username
  end

  # facebook finder
  def self.facebook_pages_for_website(url)
    doc = hpricot_doc(url)
    return nil if doc.nil?

    fb_href_elements = (doc.search("[@href*=facebook.com]"))
    fb_div_elements = (doc.search("[@data-href*=facebook.com/]"))

    fb_href_elements = fb_href_elements.map{ |e| e['href']} if fb_href_elements.present?
    fb_div_elements = fb_div_elements.map{ |e| e['data-href']} if fb_div_elements.present?

    fb_elements  = []
    fb_elements +=fb_href_elements if fb_href_elements.present?
    fb_elements += fb_div_elements if fb_div_elements.present?
    fb_elements
  end

  def self.pagename_from_facebook_page_url(facebook_page_url)
    return nil if facebook_page_url.nil?
    pagename = nil
    begin
      u = URI.parse(facebook_page_url.downcase)
      u = URI.parse("http://#{facebook_page_url.downcase}") if u.host.nil?
      return nil unless ['www.facebook.com', 'facebook.com'].include?(u.host)
      flat = facebook_page_url.downcase.gsub(/\/\//, '')
      tokens = flat.split('/')
      return nil unless tokens.present?
      return nil unless 2 == tokens.size
      pagename = tokens[1] if facebook_pagename_is_valid?(tokens[1])
    rescue Exception => e
      puts e.message
      # return nil
    end
    pagename
  end

  def self.facebook_username_is_valid?(username)
    return false if username.nil?
    username_match = username.match /^[a-z\d.]{5,}$/i 
    username_match.present? and username_match.to_s == username
  end

  class << self
    # class method name aliases
    alias_method :facebook_pagename_is_valid?, :facebook_username_is_valid?
  end

end