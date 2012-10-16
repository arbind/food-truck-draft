class JobQueueService
  include Singleton  

  def enqueue(key, job)
    JobQueue.create(key: key.symbolize, job: job)
  end

  def dequeue(key)
    entry = JobQueue.where(key: key.symbolize).asc(:created_at).limit(1).first
    return nil if entry.nil?
    entry.delete
    entry.job
  end

  def peek(key)
    entry = JobQueue.where(key: key.symbolize).asc(:created_at).limit(1).first
    return nil if entry.nil?
    entry.job
  end

  # handlers
  def queue_tweet_stream_friend_ids_to_materialize_craft(tweet_stream_api_accounts=nil)
    accounts = *tweet_stream_api_accounts
    accounts = TweetApiAccount.streams unless accounts.present?
    accounts.each do |stream|
      puts ":: #{Thread.current[:name]}: queue_friend_ids(#{stream.screen_name}) "
      return unless stream.is_tweet_streamer

      stream.remote_pull!
      new_friends_count = 0
      stream.friend_ids.each do |fid|
        if TwitterCraft.where(web_craft_id: "#{fid}").empty? # only queue TwitterCrafts that do not already exist
          JobQueue.service.enqueue(:make_craft_for_twitter_id, {twitter_id: fid, tweet_stream_id: stream.twitter_id})
          new_friends_count +=1
        end
      end
      puts ":: #{stream.screen_name} queued #{new_friends_count} to_materialize_craft for friend_ids_" unless new_friends_count.zero?
        # craft = Craft.materialize_from_twitter_id(fid)
          # client = TwitterService.instance.admin_client
          # user = client.user(fid)
          # update HoverCrafts also
    end
  rescue Exception => e
    puts e.message
    puts e.backtrace    
  end

  def dequeue_tweet_stream_friend_ids_to_materialize_craft
    puts ":: Dequeueing twitter friend jobs"
    while job=JobQueue.dequeue(:make_craft_for_twitter_id)
      tid = job['twitter_id']
      next if TwitterCraft.where(web_craft_id: "#{tid}").present? # don't create it if it already exists

      tweet_stream_id = job['tweet_stream_id']
      next unless tweet_stream_id.present?
      begin
        craft = Craft.service.materialize_from_twitter_id(tid, tweet_stream_id)
        # +++ ad rescue YelpError RateLimited
      rescue Twitter::Error::RateLimited => e
        puts "!! job queue service Twitter::Error::RateLimited"
        puts "!! Rate Limit Reached, Ending Process"
        JobQueue.service.enqueue(:make_craft_for_twitter_id, job) # rate limit exceeded, requeue this for later processing
        break
      rescue Exception => e
        puts "!! job queue service Exception" # couldn't process this - don't requeue again to avoid infinite error loop
        puts e.message
        puts e.backtrace
      end
    end
  rescue Exception => e
    puts e.message
    puts e.backtrace
  end

end
