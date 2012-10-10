BACKGROUND_JOBS = {}

def launch_chron_job_to_materialize_crafts
  # Scans all tweetstreams to find new friends that were followed.
  # Crafts are automatically created for all new friends that were found.
  BACKGROUND_JOBS[:materialize_tweet_stream_friends]  ||= Thread.new do
    Thread.current[:name] = :materialize_crafts_from_tweet_stream_friends
    Thread.current[:type] = :chron
    Thread.current[:description] = 'Materializes crafts for any new friends that have been added to a Twitter TweetStreams account'
    puts ":: #{Thread.current[:name]}: Thread Launched"
    sleep 120 # allow a few moments for the webserver to load
    loop do
      TweetStreamService.instance.refresh_tweet_streams # load the latest friends
      JobQueueService.instance.queue_tweet_stream_friend_ids_to_materialize_craft
      JobQueueService.instance.dequeue_tweet_stream_friend_ids_to_materialize_craft
      
      puts ":: Dequeueing hovercraft jobs"
      # launch_chron_job_to_materialize_crafts_from_approved_hover_crafts
      # while cid=JobQueue.service.dequeue(:make_hover_craft_for_new_twitter_friend)
        # +++ todo create hover craft
      # end
      sleep 1*60*60 # check every 1 hour
    end
  end
end

def launch_chron_job_to_detect_duplicates
end

def launch_initializer_to_refresh_tweet_streams
  BACKGROUND_JOBS[:verify_tweet_accounts_and_start_streaming]  ||= Thread.new do
    Thread.current[:name] = :verify_tweet_accounts_and_start_streaming
    Thread.current[:type] = :initializer
    Thread.current[:description] = 'Refresh tweet streams'
    sleep 4 # allow a few moments for the webserver to load
    puts ":: #{Thread.current[:name]}: Thread Launched"
    TweetStreamService.instance.refresh_tweet_streams
  end
end

def launch_initializers
  launch_initializer_to_refresh_tweet_streams
end

def launch_chron_jobs
  launch_chron_job_to_materialize_crafts
  launch_chron_job_to_detect_duplicates
end

if RUNNING_IN_SERVER
  puts ":: Launching Initializer Threads"
  Rails.application.config.after_initialize do
    launch_initializers
  end
end

if RUNNING_IN_SERVER and LAUNCH_THREADS
  puts ":: Launching Background Threads"
  Rails.application.config.after_initialize do
    launch_chron_jobs
  end
else
  puts ":: Background Threads will not be launched"
end
