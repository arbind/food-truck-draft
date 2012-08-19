class Craft
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid

  field :name
  field :phone_number
  field :address, default: nil
  field :coordinates, :type => Array, default: [nil, nil] 
  # mongoid stores [long, lat] - which is backwards from normal convention
  # geocorder knows this, but expects [lat, lng]

  field :yelp_id
  field :twitter_id
  field :facebook_id
  field :googleplus_id

  field :geo_coordinate_history, :type => Array

  has_and_belongs_to_many :organizers

  geocoded_by :address                    # can also be an IP address
  reverse_geocoded_by :coordinates
  after_validation :geocode_this_location # auto-fetch coordinates


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

  def geopoint() [lat, lng] end # this is opposite of how mongoid stores it!
  alias_method :lat_lng, :geopoint
  alias_method :lat_long, :geopoint
  alias_method :geo_coordinate, :geopoint

  def geopoint=(latlng) lat=latlng[0]; lng=latlng[1] end
  alias_method :lat_lng=, :geopoint=
  alias_method :lat_long=, :geopoint=
  alias_method :geo_coordinate=, :geopoint=
  # /geocoding  aliases

private
  def geocode_this_location
    geocode if changes[:address].present?
    return true
  end


end
