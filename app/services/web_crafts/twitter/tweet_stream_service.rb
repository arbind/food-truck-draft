class TweetStreamService
  include Singleton

  def start_listening
    streams_started = 0
    TweetStreamAccount.all.each do |craft_stream|
      streams_started += start_stream(craft_stream)
    end
    streams_started
  end

  def stream_threads
    @_threads ||= {}
  end

private

  def start_stream(craft_stream)
    thread = stream_threads[craft_stream.twitter_username]
    if thread.present?
      puts "............Thread found for #{craft_stream.twitter_username} present: #{thread.present?} alive: #{thread.alive?} state: #{thread.state} connected: #{thread[:connected]}"
    else
      puts "............Thread NOT found for #{craft_stream.twitter_username}"
    end

    return 0 if (thread.present? and thread[:connected])

    thread = Thread.new do
      Thread.current[:name]           = craft_stream.twitter_username
      Thread.current[:start_time]     = Time.now()
      Thread.current[:last_tweet_at]  = nil
      Thread.current[:description]    = :"TweetStream Listener Thread"

      # cfg = {
      #   auth_method: :oauth, 
      #   consumer_key: craft_stream.oauth_config["consumer_key"] || craft_stream.oauth_config[:consumer_key],
      #   consumer_secret: craft_stream.oauth_config["consumer_secret"] || craft_stream.oauth_config[:consumer_secret],
      #   oauth_token: craft_stream.oauth_config["oauth_token"] || craft_stream.oauth_config[:oauth_token],
      #   oauth_token_secret: craft_stream.oauth_config["oauth_token_secret"] || craft_stream.oauth_config[:oauth_token_secret]
      # }

      cfg = craft_stream.twitter_config

      Thread.current[:connected]  = false
      client = TweetStream::Client.new(cfg)
      Thread.current[:client] = client
      Thread.current[:connected]  = true
      Thread.current[:state]  = :connected

      client.on_limit do |skip_count| 
        # handle rate limit
        Thread.current[:connected]  = true
        Thread.current[:state]  = :rate_limited
        puts "limit reached! skiped #{skip_count}"
      end.on_error do |message|
        Thread.current[:connected]  = true
        Thread.current[:state]  = :error
        puts "---#{craft_stream.twitter_username}: ERROR!"
        # Twitter may be momentarily down - no need to do anything
      end.on_reconnect do |timeout, retries|
        Thread.current[:connected]  = false
        Thread.current[:state]  = :disconnected
        puts "---#{craft_stream.twitter_username}: RECONNECT REQUIRED!"
        # need to terminate this listener thread and start a new one
      end.on_delete do |status_id, user_id|
        # handle deleted tweet
        # Tweet.delete(status_id)
        Thread.current[:connected]  = true
        Thread.current[:state]  = :listening
        puts "---#{craft_stream.twitter_username}: DELETE!"
        puts "tweet [#{status_id}] was deleted by #{user_id}"
      end.userstream do |status|
        Thread.current[:last_tweet_at]  = Time.now
        Thread.current[:connected]  = true
        Thread.current[:state]  = :listening
        puts "---#{craft_stream.twitter_username}: TWEET"
        puts "#{status.text}"
      end
    end
    stream_threads[craft_stream.twitter_username] = thread
    1
  end

end