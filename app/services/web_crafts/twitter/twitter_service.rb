class TwitterService < WebCraftService
  MUTEX = Mutex.new
  include Singleton

  @_twitter_clients = {}
  @@_admin_account_idx = 0
  @@_admin_account_last_accessed_at = nil

  attr_reader :webservice_client

  def self.web_craft_class() TwitterCraft end

  # def self.rate_limit() instance.twitter_client.rate_limit_status.remaining_hits end
  # def self.time_until_rate_limit_resets() Util.normalized_time(instance.twitter_client.rate_limit_status.reset_time) end
  # def self.how_long_until_rate_limit_resets?() Util.how_long_from(instance.twitter_client.rate_limit_status.reset_time) end

  def twitter_api_rate_limit
    # +++ move to app config
    @@_admin_account_access_rate_limit ||= 50 # times per hour
  end

  def twitter_clients() @_twitter_clients ||= {} end

  def next_admin_account!
    # ! this method may sleep the thread in order to stay within twitter rate limits !
    # add more api admin accounts (non streaming) to help avoid sleeping
    MUTEX.synchronize do
      admin_accounts = TweetApiAccount.admins.asc(:created_at)
      num_admins =  admin_accounts.count
      return nil if num_admins.zero?
      @@_admin_account_idx += 1
      @@_admin_account_idx = 0 if @@_admin_account_idx.eql? num_admins

      access_frequency =  (3600.0/(num_admins * twitter_api_rate_limit)).to_i

      time_elapsed_since_last_access = 1000000
      time_elapsed_since_last_access = (Time.now - @@_admin_account_last_accessed_at) if @@_admin_account_last_accessed_at.present?

      if (time_elapsed_since_last_access < access_frequency)
        wait_time =  (1 + access_frequency - time_elapsed_since_last_access).to_i
        puts ":: Enforcing twitter Rate Limit(#{twitter_api_rate_limit}/hour): Sleeping for #{wait_time} sec"
        sleep wait_time
      end

      account = admin_accounts[@@_admin_account_idx]
      @@_admin_account_last_accessed_at = Time.now
      account
    end
  end

  def twitter_client(twitter_account=nil)
    admin_account = twitter_account
    admin_account ||= next_admin_account!
    return nil if admin_account.nil?

    client = twitter_clients[admin_account.twitter_id]
    if client.nil?
      client = Twitter::Client.new(admin_account.twitter_oauth_config)
      twitter_clients[admin_account.twitter_id] = client if admin_account.twitter_id.present?
    end
    client
  rescue Exception => e
    twitter_clients.delete(admin_account.twitter_id) if (admin_account.present? and admin_account.twitter_id.present?)
    puts e.message
    puts e.backtrace
    nil
  end

  def delete_twitter_client(twitter_account)
    return nil if (twitter_account.nil? or twitter_account.twitter_id.nil?)
    twitter_clients.delete(twitter_account.twitter_id)
  end

  # def self.hover_craft(twitter_screen_name_or_url)
  #   #scrape from web page (does not use api) 
  #   username = Web.service_id_from_string_or_href(twitter_screen_name_or_url, :twitter);
  #   return nil unless username.present?

  #   username.downcase!
  #   href = "https://twitter.com/#{username}"
  #   doc = doc = Web.hpricot_doc(href)
  #   return nil unless doc.present?

  #   name = doc.search('h1 .fullname').text().squish
  #   screen_name = doc.search('.screen-name').text().squish.downcase
  #   screen_name.slice!(0) # slice off the @ in front of the screen name

  #   # validate webpage url
  #   website = doc.search('.url a[@href]').text().squish.downcase
  #   if website
  #     begin
  #       u = URI.parse(website)
  #       u = URI.parse("http://#{website}") unless u.host.present?
  #       website = nil if u.host.nil? or 'twitter.com'.eql? u.host
  #     rescue
  #     end
  #   end

  #   hover_craft = {
  #     twitter_name: name,
  #     twitter_username: screen_name || username,
  #     twitter_href: href,
  #     twitter_website: website,
  #     twitter_following_list: nil
  #   }
  # end

  def self.raw_fetch(web_craft_id, fetch_timeline=false) # get the user and their timeline
    tid = "#{web_craft_id}"
    tid = tid.to_i if tid.integer?
    puts "Fetching id: #{tid}"
    client = instance.twitter_client
    twitter_user = client.user(tid) # twitter id should be number, but screen_name will be string

    if twitter_user
      web_craft_hash = twitter_user.to_hash
    else
      web_craft_hash = nil
    end

    if(true===fetch_timeline and web_craft_hash.present?)
      timeline = client.user_timeline(tid)
      if timeline
        timeline = timeline.map do |status|
          tweet_hash = status.to_hash
          # tweet_hash[:tweet_id] = tweet_hash.delete(:id);
          tweet_hash.delete(:user)
          tweet_hash
        end
        web_craft_hash[:timeline] = timeline

        # grab an oembed for the last tweet 
        # if timeline.first.present?
        #   oembed_id = timeline.first[:id]
        #   maxwidth = 325
        #   hide_thread = false
        #   oembed_url = "https://api.twitter.com/1/statuses/oembed.json?id=#{oembed_id}&omit_script=true&hide_thread=#{hide_thread}&maxwidth=#{maxwidth}" if oembed_id.present?
        #   begin
        #     oembed_party = HTTParty.get oembed_url
        #     oembed_hash = oembed_party.parsed_response if oembed_party.parsed_response.present?
        #     web_craft_hash[:oembed] = oembed_hash if oembed_hash.present?
        #   rescue Exception => e
        #     puts e.message
        #     puts e.backtrace
        #   end
        # end

      end
    end
    web_craft_hash
  rescue Twitter::Error::RateLimited => e
    puts "twitter service Twitter::Error::RateLimited"
    puts e.message
    raise e
  end

  def self.web_fetch(web_craft_id) # fetch and normalize a web_craft_hash for update_atrributes
    web_craft_hash = raw_fetch(web_craft_id)
    return nil unless web_craft_hash.present?

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
  
  def self.user_for_id(twitter_id)
    url = "https://api.twitter.com/1/users/show.json?id=#{twitter_id}"
    Web.read_url(url)
  end

  # find the website of an account
  def self.website_for_account(user_id_or_url)
    user_id = id_from_href(user_id_or_url) || user_id_or_url
    return nil if user_id.nil?

    web_craft_hash = raw_fetch(user_id, false)
    web_craft_hash[:url]
  rescue
    ""
  end 

  # webpage scraping
  def self.hrefs_in_hpricot_doc(doc)
    hrefs = Web.hrefs_in_hpricot_doc(doc, 'twitter.com')
    # See if there is a twitter widget in the doc (where twitter hrefs get added after document ready) and pick off the user
    # e.g. <script> new TWTR.Widget() ... render().setUser('bemorepacific').start() ... </script>
    twtr_widget_user_match = doc.search('script[text()*=TWTR.Widget]').text().match /^.*\.setUser\([\'\"](.*)[\'\"]\).*/
    if twtr_widget_user_match # get the user name
      twtr_user = twtr_widget_user_match[1] 
      hrefs.push ("http://www.twitter.com/#{twtr_user}") if twtr_user # artificially construct an href to twitter
    end
    hrefs
  end

  def self.id_from_href(href) # get the twitter screen_name or id from a url or href
    return nil if href.nil?

    screen_name = nil
    begin
      url = href.downcase.split('?')[0] # strip off query params
      u = URI.parse(url)
      u = URI.parse("http://#{url}") if u.host.nil?
      return nil unless ['www.twitter.com', 'twitter.com'].include?(u.host)
      flat = url.gsub(/\/\//, '')
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
    id_match = id.match /^[\S]+$/ 
    id_match.present? and id_match.to_s == id
  end

  private
  def initialize() @webservice_client = nil end # update with Twitte client if necessary
  def self.client() instance.webservice_client end

end