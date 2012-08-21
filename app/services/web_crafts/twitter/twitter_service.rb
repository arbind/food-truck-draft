class TwitterService < WebCraftService
  include Singleton
  attr_reader :webservice_client

  def self.web_craft_class() TwitterCraft end

  def self.fetch_remote_web_craft_hash(web_craft_id) # fetch and normalize a web_craft_hash for update_atrributes
    id = "#{web_craft_id}"
    twitter_user = Twitter.user(id)
    return nil if twitter_user.nil?
    webcraft_hash = twitter_user.to_hash

    webcraft_hash[:is_protected] = webcraft_hash.delete(:protected)
    webcraft_hash[:twitter_account_created_at] = webcraft_hash.delete(:created_at)

    #remove unneeded atts
    webcraft_hash.delete(:status)
    webcraft_hash.delete(:id_str)
    webcraft_hash.delete(:contributors_enabled)
    webcraft_hash.delete(:is_translatorfollowing)
    webcraft_hash.delete(:follow_request_sent)
    webcraft_hash.delete(:notifications)

    #locate url for _reasonably_small image: it seems to be a bigger than the _normal size
    image_url = webcraft_hash[:profile_image_url]
    webcraft_hash[:profile_image_url_bigger] = image_url # default
    bigger_image_url = image_url.gsub(/_normal\./, '_reasonably_small.') if image_url
    webcraft_hash[:profile_image_url_bigger] = bigger_image_url if  Web.image_exists?(bigger_image_url)

    timeline = Twitter.user_timeline(id)
    if timeline
      timeline = timeline.map do |status|
        tweet_hash = status.to_hash
        tweet_hash[:tweet_id] = tweet_hash.delete(:id);
        tweet_hash.delete(:user)
        tweet_hash
      end
      webcraft_hash[:timeline] = timeline
    end
    webcraft_hash
  end

    

  # def self.pull(screen_name)
  #   begin
  #     tuser = Twitter.user(screen_name)
  #     return nil if tuser.nil?

  #     # create or updates the twitter presence
  #     twitter_presence = TwitterCraft.materialize_from_twitter(tuser.to_hash)
  #     # create or update the timeline
  #     timeline = Twitter.user_timeline(screen_name) 
  #     twitter_presence.update_timeline(timeline)

  #     return twitter_presence
  #   rescue Exception => e 
  #     puts e.message
  #     return nil
  #   end
  # end


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
      # return nil
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