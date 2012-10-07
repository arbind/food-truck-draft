LAUNCH_THREADS = true
# LAUNCH_THREADS = false
RUNNING_IN_CONSOLE = defined?(Rails::Console)
RUNNING_IN_SERVER = ! RUNNING_IN_CONSOLE

puts ":: Running in server" if RUNNING_IN_SERVER
puts ":: Running in console" if RUNNING_IN_CONSOLE

# Fire up redis
uri = URI.parse(ENV["REDISTOGO_URL"] || "redis://localhost:6379/" )
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)


# ping the server to keep from idling out
if Rails.env.production? and RUNNING_IN_SERVER and LAUNCH_THREADS
  puts ":: Initializing Ping Thread"
  PING_URI = URI.parse("http://www.food-truck.me/ping.json")
  ping_thread = Thread.new do
    Thread.current[:name] = :ping
    Thread.current[:description] = "Pings server every 8 minutes"
    loop do
      sleep 8*60 # 8 minutes
      Net::HTTP.get_response(PING_URI)
    end
  end
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

