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


# FTMMIN01
# FTMMIN02 tellariadne+ftmadmin02@gmail.com
# FTMMIN03 tellariadne+ftmadmin03@gmail.com
# FTMMIN04 tellariadne+ftmadmin04@gmail.com
# FTMMIN05 tellariadne+ftmadmin05@gmail.com

# FTMMIN06 tellariadne+ftmadmin06@gmail.com
# FTMMIN07 tellariadne+ftmadmin07@gmail.com
# FTMMIN08 tellariadne+ftmadmin08@gmail.com
# FTMMIN09 tellariadne+ftmadmin09@gmail.com
# FTMMIN10 tellariadne+ftmadmin10@gmail.com
# FTMMIN11 tellariadne+ftmadmin11@gmail.com
# FTMMIN12 tellariadne+ftmadmin12@gmail.com

