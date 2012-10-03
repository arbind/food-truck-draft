# Fire up redis
uri = URI.parse(ENV["REDISTOGO_URL"] || "redis://localhost:6379/" )
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

# start listening to tweet streamers once the server loads
Rails.application.config.after_initialize do
  Thread.new do
    sleep 8 # allow a moment for the webserver to load
    TweetStreamService.instance.start_listening
  end
end


# ping the server to keep from idling out
if Rails.env.production? 
  puts ":: Initializing Ping Thread"
  PING_URI = URI.parse("http://www.food-truck.me/ping.json")
  ping_thread = Thread.new do
    loop do
      sleep 8*60 # 8 minutes
      Net::HTTP.get_response(PING_URI)
    end
  end
  ping_thread[:thread_name] = "ping self (every 8m)"
else
  puts ":: No Ping Thread Started"
end
