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
          JobQueue.service.enqueue(:make_craft_for_twitter_id, {twitter_id: fid, default_address: stream.address, tweet_stream_id: stream._id.to_s})
          new_friends_count +=1
        end
        puts "^^Queued #{new_friends_count} to make_craft_for_twitter_id from #{stream.screen_name} tweet stream" unless new_friends_count.zero?
      end
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

      default_address = job['default_address']
      tweet_stream_id = job['tweet_stream_id']
      puts job
      puts ":: #{Thread.current[:name]}: Creating Craft for twitter id: #{job['twitter_id']} )"
      begin
        craft = Craft.materialize_from_twitter_id(tid, default_address, tweet_stream_id)
      rescue Twitter::Error::RateLimited => e
        puts "job queue service Twitter::Error::RateLimited"
        puts "Rate Limit Reached, Ending Process"
        JobQueue.service.enqueue(:make_craft_for_twitter_id, job) # rate limit exceeded, requeue this
        break
      rescue Exception => e
        puts "job queue service Exception"
        puts e.message
        puts e.backtrace
      end
      # create hovercraft if none found
      # set twitterinfo and tweet_stream_id on hovercraft
      # hover_craft = HoverCraft.service.materialize_from_twitter_craft(craft.twitter)
      # hover_craft.materialize_craft if hover_craft.is_ready_to_make?
        # find hover craft by twitter_id or twitter_username.downcase
        # mark as duplicate if more than one found
    end
  rescue Exception => e
    puts e.message
    puts e.backtrace
  end

end
