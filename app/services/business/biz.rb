class Biz
  field :name
  field :phone_number
  field :location
  field :geo_coordinate, type => Array
  field :geo_coordinate, type => Array

  field :yelp_id
  field :twitter_id
  field :facebook_id
  field :googleplus_id

  index [[ :geo_coordinate, Mongo::GEO2D ]]

  before_filter :set_location
  # def set_location
  #   self.location = Geocoder.search(self.address).first.coordinates if self.address_changed? || self.new_record?
  # end

end

see :
http://blog.joshsoftware.com/2011/04/13/geolocation-rails-and-mongodb-a-receipe-for-success/

see :
GlobalMaps4Rails

see:
http://stackoverflow.com/questions/6640697/how-do-i-query-objects-near-a-point-with-ruby-geocoder-mongoid


see:
http://stackoverflow.com/questions/6366870/how-to-search-for-nearby-users-using-mongoid-rails-and-google-maps

lat, lng = Geocoder.search('some location').first.coordinates
result = Business.near(:location => [lat, lng])

‘rake db:mongoid:create_indexes’