class TweetStreamService
  include Singleton

  def start_listening
    streams_started = 0
    TweetStreamAccount.all.each do |tweet_stream|
      streams_started += start_stream(tweet_stream)
    end
    streams_started
  end

  def active_streams
    @_active_streams ||= {}
  end

private

  def start_stream(tweet_stream)
    active_stream = active_streams[tweet_stream.twitter_username]
    if active_stream.present?
      puts "............#{tweet_stream.twitter_username}: active_stream found present: #{active_stream.present?} state: #{active_stream[:state]} connected: #{active_stream[:connected]}"
    else
      puts "............#{tweet_stream.twitter_username}: No active_stream found"
    end

    if (active_stream.present? and active_stream[:connected])
      puts "............#{tweet_stream.twitter_username} Stream already started, returning without doing anything"
      return 0 
    elsif active_stream.present? and active_stream[:client].present?
      puts "............#{tweet_stream.twitter_username} Stream closing previous connection"
      # close out a previous client that got disconnected
      begin
        client = active_stream[:client]
        client.stop
        active_stream[:client] = nil
      rescue Exception => e
        puts ":::::::::::::::::::"
        puts e.message
        puts e.backtrace
        puts ":::::::::::::::::::"
      end
    else
      puts "............#{tweet_stream.twitter_username} Stream does not exist, creating a new one!"      
    end

    # activate this stream
    puts "............#{tweet_stream.twitter_username} Activating Stream!"      
    active_streams[tweet_stream.twitter_username] = nil
    active_stream = {}
    active_streams[tweet_stream.twitter_username] = active_stream

    active_stream[:twitter_id]     = tweet_stream.twitter_id
    active_stream[:name]           = tweet_stream.twitter_username
    active_stream[:start_time]     = Time.now()
    active_stream[:description]    = :"TweetStream Listener Thread"
    active_stream[:last_tweet_at]  = nil

    active_stream[:connected]  = false
    active_stream[:state]  = nil

    begin
      cfg = tweet_stream.twitter_oauth_config
      client = TweetStream::Client.new(cfg)

      active_stream[:client] = client
      active_stream[:connected]  = true
      active_stream[:state]  = :connected

      client.on_limit do |skip_count| 
        # handle rate limit
        active_stream[:connected]  = true
        active_stream[:state]  = :rate_limited
        puts "limit reached! skiped #{skip_count}"
      end.on_error do |message|
        active_stream[:connected]  = true
        active_stream[:state]  = :error
        puts "---#{tweet_stream.twitter_username}: ERROR!"
        # Twitter may be momentarily down - no need to do anything
      end.on_reconnect do |timeout, retries|
        active_stream[:connected]  = false
        active_stream[:state]  = :disconnected
        puts "---#{tweet_stream.twitter_username}: RECONNECT REQUIRED!"
        # need to terminate this listener thread and start a new one
      end.on_delete do |status_id, user_id|
        # handle deleted tweet
        # Tweet.delete(status_id)
        active_stream[:connected]  = true
        active_stream[:state]  = :listening
        puts "---#{tweet_stream.twitter_username}: DELETE!"
        puts "tweet [#{status_id}] was deleted by #{user_id}"
      end.userstream do |status|
        active_stream[:last_tweet_at]  = Time.now
        active_stream[:connected]  = true
        active_stream[:state]  = :listening
        puts "---#{tweet_stream.twitter_username}: TWEET"
        puts "#{status.text}"
      end
      return 1
    rescue Exception => e
      puts ":::::::::::::::::::"
      puts e.message
      puts e.backtrace
      puts ":::::::::::::::::::"
      return 0
    end
  end

end