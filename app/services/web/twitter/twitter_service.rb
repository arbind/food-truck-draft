class TwitterService
  include Singleton
  attr_reader :twitter_client


  def self.pull(screen_name)
    begin
      tuser = Twitter.user(screen_name)
      return nil if tuser.nil?

      # create or updates the twitter presence
      twitter_presence = TwitterCraft.materialize_from_twitter(tuser.to_hash)
      # create or update the timeline
      timeline = Twitter.user_timeline(screen_name) 
      twitter_presence.update_timeline(timeline)

      return twitter_presence
    rescue Exception => e 
      puts e.message
      return nil
    end
  end



  # webpage scraping

  def self.craft_for_href(href)
    id = id_from_href(href)
    craft = pull(id) unless id.nil?
  end

  def self.hrefs_in_webpage(url)
    doc = hpricot_doc(url)
    hrefs_in_hpricot_doc(doc)
  end

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
  def initialize()  @twitter_client = Yelp::Client.new end

  def self.client() TwitterService.instance.twitter_client end

end