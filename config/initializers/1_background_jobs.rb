BACKGROUND_JOBS = {}

def launch_job_to_materialize_crafts_from_approved_hover_crafts
end

def launch_job_to_materialize_crafts_from_tweet_stream_friends
  # Scans all tweetstreams to find new friends that were followed.
  # Crafts are automatically created for all new friends that were found.
  BACKGROUND_JOBS[:materialize_tweet_stream_friends]  ||= Thread.new do
    Thread.current[:name] = :materialize_crafts_from_tweet_stream_friends
    Thread.current[:type] = :chron
    Thread.current[:description] = 'Materializes crafts for any new friends that have been added to a Twitter TweetStreams account'
    puts ":: #{Thread.current[:name]}: Thread Launched"
    sleep 120 # allow a few moments for the webserver to load
    loop do
      begin
        puts ":: Pulling streams"
        TweetApiAccount.streams[1..10].each do |stream|
          puts ":: #{Thread.current[:name]}: queue_friend_ids(#{stream.screen_name}) "
          stream.queue_friend_ids_to_materialize
        end
        puts ":: Dequeueing twitter friend jobs"
        while job=JobQueue.dequeue(:make_craft_for_twitter_id)
          puts job
          puts ":: #{Thread.current[:name]}: Creating Craft for twitter id: #{job['twitter_id']} )"
          craft = Craft.materialize_from_twitter_id(job['twitter_id'], job['default_address'], job['tweet_stream_id'])
        end
        puts ":: Dequeueing hovercraft jobs"
        # while cid=JobQueue.service.dequeue(:make_hover_craft_for_new_twitter_friend)
          # +++ todo create hover craft
        # end
      rescue Exception => e
        puts ":: #{Thread.current[:name]}: ERROR"
        puts e.message
        puts e.backtrace
      end
      sleep 60 # check once every minute
    end
  end
end

def launch_job_to_materialize_hover_crafts_for_new_tweet_stream_friends
end

def launch_job_to_detect_duplicates
end

def launch_job_to_verify_tweet_accounts_and_start_streaming
  BACKGROUND_JOBS[:verify_tweet_accounts_and_start_streaming]  ||= Thread.new do
    Thread.current[:name] = :verify_tweet_accounts_and_start_streaming
    Thread.current[:type] = :initializer
    Thread.current[:description] = 'Verify Tweet Api Accounts can login ok, and start listening to tweet streams'
    sleep 4 # allow a few moments for the webserver to load
    puts ":: #{Thread.current[:name]}: Thread Launched"
    loop do
      begin
        TweetApiAccount.verify_logins
        TweetStreamService.instance.start_listening
      rescue Exception => e
        puts e.message
        puts e.backtrace
      end
      sleep 1*60*60 # check every hour
    end
  end
end

def launch_initializers
  # launch_job_to_verify_tweet_accounts_and_start_streaming
end

def launch_chron_jobs
  launch_job_to_materialize_crafts_from_approved_hover_crafts
  launch_job_to_materialize_crafts_from_tweet_stream_friends
  launch_job_to_detect_duplicates
end

def launch_background_jobs
  launch_chron_jobs
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
    launch_background_jobs
  end
else
  puts ":: Background Threads will not be launched"
end
