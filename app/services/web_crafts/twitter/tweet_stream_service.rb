class TweetStreamService
  include Singleton

  def start_listening
    streams_started = 0
    TweetApiAccount.streams.each do |tweet_stream|
      streams_started += start_stream(tweet_stream)
    end
    streams_started
  end

  def stream_status(screen_name)
    active_stream = active_streams[screen_name]
    return :disconnected unless active_stream.present?
    active_stream[:state]
  end

  def active_streams
    @_active_streams ||= {}
  end

  def stop_stream(tweet_stream)
    active_stream = active_streams[tweet_stream.screen_name]
    return unless active_stream.present?
    client = active_stream[:client]
    puts '1 stopping!'
    if client.present?
      client.stop_stream
      client.close_connection 
    end
    puts '2 stopped!'
    active_stream[:client] = nil
    puts '3 client=nil'
    active_streams.delete(tweet_stream.screen_name)
    puts '4 active-stream = nil'
  end

  def start_stream(tweet_stream)
    active_stream = active_streams[tweet_stream.screen_name]
    if active_stream.present?
      puts "............#{tweet_stream.screen_name}: active_stream found present: #{active_stream.present?} state: #{active_stream[:state]} connected: #{active_stream[:connected]}"
    else
      puts "............#{tweet_stream.screen_name}: No active_stream found"
    end

    if (active_stream.present? and active_stream[:connected])
      puts "............#{tweet_stream.screen_name} Stream already started, returning without doing anything"
      return 0 
    elsif active_stream.present? and active_stream[:client].present?
      # close out a previous client is no longer connected
      puts "............#{tweet_stream.screen_name} Stream closing previous connection"
      stop_stream(tweet_stream)
    else
      puts "............#{tweet_stream.screen_name} Stream does not exist, creating a new one!"      
    end

    # activate this stream
    puts "............#{tweet_stream.screen_name} Activating Stream!"      
    active_streams.delete(tweet_stream.screen_name)
    active_stream = {}
    active_streams[tweet_stream.screen_name] = active_stream

    active_stream[:twitter_id]     = tweet_stream.twitter_id
    active_stream[:name]           = tweet_stream.screen_name
    active_stream[:start_time]     = Time.now()
    active_stream[:description]    = :"Tweet Stream Listener Thread"
    active_stream[:last_tweet_at]  = nil

    active_stream[:connected]  = false
    active_stream[:state]  = nil

    begin
      puts "............#{tweet_stream.screen_name} Thread Started!"      
      cfg = tweet_stream.twitter_oauth_config
      client = TweetStream::Client.new(cfg)
      puts "............#{tweet_stream.screen_name} Client Created!"

      active_stream[:thread] = Thread.current
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
        puts "---#{tweet_stream.screen_name}: ERROR!"
        # Twitter may be momentarily down - no need to do anything
      end.on_reconnect do |timeout, retries|
        active_stream[:connected]  = false
        active_stream[:state]  = :disconnected
        puts "---#{tweet_stream.screen_name}: RECONNECT REQUIRED!"
        # need to terminate this listener thread and start a new one
      end.on_delete do |status_id, user_id|
        # handle deleted tweet
        # Tweet.delete(status_id)
        active_stream[:connected]  = true
        active_stream[:state]  = :listening
        puts "---#{tweet_stream.screen_name}: DELETE!"
        puts "tweet [#{status_id}] was deleted by #{user_id}"
      end.userstream do |status|
        active_stream[:last_tweet_at]  = Time.now
        active_stream[:connected]  = true
        active_stream[:state]  = :listening
        puts "---#{tweet_stream.screen_name}: TWEET"
        puts "#{status.text}"
      end
      puts "............#{tweet_stream.screen_name} Handlers Bound!"
      puts "............#{tweet_stream.screen_name} Complete returning 1!"
      return 1
    rescue Exception => e
      puts ":::::::::::::::::::"
      puts e.message
      puts e.backtrace
      puts ":::::::::::::::::::"
      return 0
    end
    puts "............#{tweet_stream.screen_name} DoneDone!"
    return 1
  end

end