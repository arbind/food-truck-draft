class Craft
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid

  field :name
  field :phone_number, index: true
  field :email, index: true
  field :website, index: true
  field :twitter_screen_name, index: true

  # geocoder fields
  field :address, default: nil
  field :coordinates, type: Array, default: [nil, nil] # does geocoder gem auto index this?
  # mongoid stores [long, lat] - which is backwards from normal convention
  # geocorder knows this, but expects [lat, lng]

  field :geo_location_history, :type => Array # for mobile crafts like a Food Truck

  # add all nizer.name to search_tags - be sure to update list when binding to a new nizer
  field :search_tags, type: Array, default: [], index: true 

  has_many :web_crafts
  has_and_belongs_to_many :nizers # organizers

  geocoded_by :address
  reverse_geocoded_by :coordinates
  before_save :geocode_this_location # auto-fetch coordinates

  # geocoding  aliases
  alias_method :ip_address, :address
  alias_method :ip_address=, :address=

  def latitude() coordinates.last end
  alias_method :lat, :latitude

  def latitude=(lat) coordinates[1] = lat end
  alias_method :lat=, :latitude=


  def longitude() coordinates.first end
  alias_method :lng, :longitude
  alias_method :long, :longitude

  def longitude=(lng) coordinates[0] = lng end
  alias_method :lng=, :longitude=
  alias_method :long=, :longitude=
  # /geocoding  aliases

  # geo point hash representation
  def geo_point() latitude:lat, longitude:lng end
  def geo_point=(latlng_hash)
    lat   = latlng_hash[:latitude]   if latlng_hash[:latitude].present?
    lat ||= latlng_hash[:lat]        if latlng_hash[:lat].present?

    lng   = latlng_hash[:longitude]  if latlng_hash[:longitude].present?
    lng ||= latlng_hash[:long]       if latlng_hash[:long].present?
    lng ||= latlng_hash[:lng]        if latlng_hash[:lng].present?

    self.lat = lat
    self.lng = lng
  end
  alias_method :geo_coordinate, :geo_point
  alias_method :geo_coordinate=, :geo_point=
  # /geo point hash representation

private
  def geocode_this_location
    if changes[:coordinates].present?
      reverse_geocode # udate the address
      # +++ add {time, coordinates, address} to geo_location_history
    elsif changes[:address].present?
      geocode # update lat, lng
    end
    return true
  end


end



# see for google maps stuff:
# http://blog.joshsoftware.com/2011/04/13/geolocation-rails-and-mongodb-a-receipe-for-success/

# see :
# GlobalMaps4Rails

# see:
# http://stackoverflow.com/questions/6640697/how-do-i-query-objects-near-a-point-with-ruby-geocoder-mongoid


# see:
# http://stackoverflow.com/questions/6366870/how-to-search-for-nearby-users-using-mongoid-rails-and-google-maps

# lat, lng = Geocoder.search('some location').first.coordinates
# result = Business.near(:location => [lat, lng])

# ‘rake db:mongoid:create_indexes’