class TwitterService < WebCraftService
  include Singleton
  attr_reader :webservice_client

  def self.web_craft_class() TwitterCraft end

  def self.raw_fetch(web_craft_id, fetch_timeline=true) # get the user and their timeline
    id = "#{web_craft_id}"
    twitter_user = Twitter.user(id)
    if twitter_user
      web_craft_hash = twitter_user.to_hash
    else
      web_craft_hash = nil
    end

    if(true===fetch_timeline and web_craft_hash.present?)
      timeline = Twitter.user_timeline(id)
      if timeline
        timeline = timeline.map do |status|
          tweet_hash = status.to_hash
          # tweet_hash[:tweet_id] = tweet_hash.delete(:id);
          tweet_hash.delete(:user)
          tweet_hash
        end
        web_craft_hash[:timeline] = timeline
      end
    end
    web_craft_hash
  end

  def self.web_fetch(web_craft_id) # fetch and normalize a web_craft_hash for update_atrributes
    web_craft_hash = raw_fetch(web_craft_id)
    return nil if web_craft_hash.nil?

    #normalize atts
    web_craft_hash[:href] = "http://twitter.com/#{web_craft_hash[:screen_name]}"

    #remove unneeded atts
    web_craft_hash.delete(:status)
    web_craft_hash.delete(:id_str)
    web_craft_hash.delete(:contributors_enabled)
    web_craft_hash.delete(:is_translatorfollowing)
    web_craft_hash.delete(:follow_request_sent)
    web_craft_hash.delete(:notifications)

    #locate url for _reasonably_small image: it seems to be a bigger than the _normal size
    image_url = web_craft_hash[:profile_image_url]
    web_craft_hash[:profile_image_url_bigger] = image_url # default
    bigger_image_url = image_url.gsub(/_normal\./, '_reasonably_small.') if image_url
    web_craft_hash[:profile_image_url_bigger] = bigger_image_url if  Web.image_exists?(bigger_image_url)

    web_craft_hash
  end
    
  # webpage scraping
  def self.hrefs_in_hpricot_doc(doc)
    Web.hrefs_in_hpricot_doc(doc, 'twitter.com')
  end

  def self.id_from_href(href) # get the twitter screen_name or id from a url or href
    return nil if href.nil?

    screen_name = nil
    begin
      u = URI.parse(href.downcase)
      u = URI.parse("http://#{href.downcase}") if u.host.nil?
      return nil unless ['www.twitter.com', 'twitter.com'].include?(u.host)
      flat = href.downcase.gsub(/\/\//, '')
      tokens = flat.split('/')
      return nil unless tokens.present?

      case tokens.size
        when 2
          screen_name = tokens[1] if id_is_valid?(tokens[1])
        when 3
          screen_id = tokens[2]
          screen_name = screen_id if ("#!" == tokens[1] and id_is_valid?(screen_id) )
        else
          # screen_name = nil
      end
    rescue Exception => e
      puts e.message
      puts e.backtrace
    end
    screen_name
  end
  # /webpage scraping

  def self.id_is_valid?(id) twitter_username_is_valid?(id) end
  def self.twitter_username_is_valid?(id)
    return false if id.nil?
    id_match = id.match /[A-Za-z0-9_]+/ 
    id_match.present? and id_match.to_s == id
  end

  private
  def initialize() @webservice_client = nil end # update with Twitte client if necessary
  def self.client() instance.webservice_client end

end