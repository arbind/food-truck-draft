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
    loop do
      begin
        puts ":: Pulling streams"
        TweetApiAccount.streams.each do |stream|
          puts ":: #{Thread.current[:name]}: TweetStream.pull(#{stream.screen_name}) "
          stream.remote_pull!
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

def launch_background_jobs
  launch_job_to_materialize_crafts_from_approved_hover_crafts
  launch_job_to_materialize_crafts_from_tweet_stream_friends
  launch_job_to_detect_duplicates
end

if RUNNING_IN_SERVER
  puts ":: Background Threads will be launched in 20 seconds"
  Rails.application.config.after_initialize do
    Thread.new do
      sleep 20 # allow a few moments for the webserver to load
      launch_background_jobs
    end
  end
else
  puts ":: Background Threads will not be launched"
end


