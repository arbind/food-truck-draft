LAUNCH_THREADS = true
# LAUNCH_THREADS = false
RUNNING_IN_CONSOLE = defined?(Rails::Console)
RUNNING_IN_RAKE_TASK = global_variables.include? "$rakefile"
RUNNING_IN_SERVER = ! ( RUNNING_IN_CONSOLE  or RUNNING_IN_RAKE_TASK)

puts ":: Running in server" if RUNNING_IN_SERVER
puts ":: Running in rake task" if RUNNING_IN_RAKE_TASK
puts ":: Running in console" if RUNNING_IN_CONSOLE

# Fire up redis
uri = URI.parse(ENV["REDISTOGO_URL"] || "redis://localhost:6379/" )
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)


# ping the server to keep from idling out
if Rails.env.production? and RUNNING_IN_SERVER
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

# foodTRUCK2012

# FT USLABR         tellariadne+FTSUSLABR@gmail.com         FTSUSLABR         Baton Rouge food truck lover      Baton Rouge, LA, USA
# FT USNMAL         tellariadne+FTSUSNMAL@gmail.com         FTSUSNMAL         Albuquerque food truck lover      Albuquerque, NM, USA 
# FT USVARICH       tellariadne+FTSUSVARICH@gmail.com       FTSUSVARICH       Richmond food truck lover         Richmond, VA, USA 
# FT USFLJACK       tellariadne+FTSUSFLJACK@gmail.com       FTSUSFLJACK       Jacksonville food truck lover     Jacksonville, FL, USA 
# FT USTNMEM        tellariadne+FTSUSTNMEM@gmail.com        FTSUSTNMEM        Memphis food truck lover          Memphis, TN, USA 
# FT USLANO         tellariadne+FTSUSLANO@gmail.com         FTSUSLANO         New Orleans food truck lover      New Orleans, LA, USA 
# FT USMOKC         tellariadne+FTSUSMOKC@gmail.com         FTSUSMOKC         Kansas City food truck lover      Kansas City, MO, USA 
# FT USHIHON        tellariadne+FTSUSHIHON@gmail.com        FTSUSHIHON        Honolulu food truck lover         Honolulu, HI, USA 
# FT USWIMIL        tellariadne+FTSUSWIMIL@gmail.com        FTSUSWIMIL        Milwaukee food truck lover        Milwaukee, WI, USA 
# FT USPAPITTS      tellariadne+FTSUSPAPITTS@gmail.com      FTSUSPAPITTS      Pittsburgh food truck lover       Pittsburgh, PA, USA 
# FT USTXSANTONIO   tellariadne+FTSUSTXSANTONIO@gmail.com   FTSUSTXSANTONIO   San Antonio food truck lover      San Antonio, TX, USA 
# FT USFLTAMPA      tellariadne+FTSUSFLTAMPA@gmail.com      FTSUSFLTAMPA      Tampa food truck lover            Tampa, FL, USA 
# FT USCASACTO      tellariadne+FTSUSCASACTO@gmail.com      FTSUSCASACTO      Sacramento food truck lover       Sacramento, CA, USA 
# FT USNCRALEIGH    tellariadne+FTSUSNCRALEIGH@gmail.com    FTSUSNCRALEIGH    Raleigh food truck lover          Raleigh, NC, USA 

# FT USOHDAYTON     tellariadne+FTSUSOHDAYTON@gmail.com     FTSUSOHDAYTON        Dayton food truck lover           Dayton, OH, USA
# FT USOHCOLUMBUS   tellariadne+FTSUSOHCOLUMBUS@gmail.com   FTSUSOHCOLUMBUS    Columbus food truck lover         Columbus, OH, USA 
# FT USOHCLEV       tellariadne+FTSUSOHCLEV@gmail.com       FTSUSOHCLEV       Cleveland food truck lover        Cleveland, OH, USA 
# FT USOHCIN        tellariadne+FTSUSOHCIN@gmail.com        FTSUSOHCIN        Cincinnati food truck lover       Cincinnati, OH, USA

# FT CABCVAN        tellariadne+FTSCABCVAN@gmail.com        FTSCABCVAN        Vancouver food truck lover        Vancouver, BC, Canada

# FT AUNSWSYDNEY    tellariadne+FTSAUNSWSYDNEY@gmail.com    FTSAUNSWSYDNEY    Sydney food truck lover!          Sydney, NSW, Australia
# FT AUSAADELAIDE   tellariadne+FTSAUSAADELAIDE@gmail.com   FTSAUSAADELAIDE   Adelaide food truck lover!        Adelaide, SA, Australia
# FT AUWAPERTH      tellariadne+FTSAUWAPERTH@gmail.com      FTSAUWAPERTH      Perth food truck lover!           Perth, WA, Australia
# FT AUQLDBRISB     tellariadne+FTSAUQLDBRISB@gmail.com     FTSAUQLDBRISB     Brisbane food truck lover!        Brisbane, QLD, Australia
