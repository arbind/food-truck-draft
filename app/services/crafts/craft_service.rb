class CraftService
  include Singleton

  def self.service() instance end
  def service() CraftService.instance end

  def materialize_from_twitter_id(tid, tweet_stream_id=nil)
    puts ":: Materializing Craft from twitter id #{tid}"
    streamer = TweetApiAccount.streams.where(twitter_id: tweet_stream_id).first
    default_address = streamer.address.downcase! if streamer.present? and streamer.address.present?
    twitter_craft = TwitterCraft.pull(tid) rescue nil
    if twitter_craft.nil?
      puts "^^ Twitter user #{tid} could not be pulled!"
      return nil
    end

    updates = {}
    updates[:address] = default_address if default_address.present? # use the streamer's address over the actual twitter account's address
    updates[:tweet_stream_id] = tweet_stream_id if tweet_stream_id.present? and twitter_craft.tweet_stream_id.nil?
    twitter_craft.update_attributes(updates)

    craft = twitter_craft.craft || Craft.create
    craft.bind(twitter_craft)
    puts ":: materialized #{twitter_craft.screen_name} "
    hc = HoverCraft.service.materialize_from_craft(craft)
    craft
  rescue Exception => e 
    puts "!! craft Exception"
    puts e.message
    raise e
  end

  def materialize(provider_id_username_or_href, provider = nil)
    web_craft = nil
    if provider_id_username_or_href.looks_like_url? # look for web_craft by href
      web_craft = WebCraft.where(hrefs: provider_id_username_or_href).first
    else # look for web_craft by screen name or social id
      web_craft = WebCraft.where(provider_username_tags: provider_id_username_or_href).or(provider_id_tags: provider_id_username_or_href).first
    end
    return web_craft.craft if (web_craft && web_craft.craft)

    # didn't find a craft, lets scrape the web to get web_crafts for provider_id_username_or_href
    web_crafts_map = Web.web_crafts_map(provider_id_username_or_href, provider)
    web_crafts = web_crafts_map[:web_crafts] # all the web_crafts in an array
    return nil unless web_crafts.present? # do not create a new craft if there are no web_crafts

    #see if an already existing craft was found with any of these web_crafts
    crafts = web_crafts.collect(&:craft).reject{|i| i.nil?} # collect all the parent crafts for the web_crafts
    return crafts.first if crafts.present?  # return the parent craft if any webcraft was found

    # we have some web_crafts, and none of them have a parent craft, lets create a new one
    puts "web_crafts_map[:status_strength] = #{web_crafts_map[:status_strength]}"
    if Web::STRENGTH_low < web_crafts_map[:status_strength]
      puts "creating craft"
      craft = Craft.create
      craft.bind(web_crafts)
      craft.approved = true if Web::STRENGTH_auto_approve == web_crafts_map[:status_strength]
    else
      puts "no craft made"
      craft = nil
    end
    craft
  end

end