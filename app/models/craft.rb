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
  field :coordinates, :type => Array, default: [nil, nil] # does geocoder gem auto index this?
  # mongoid stores [long, lat] - which is backwards from normal convention
  # geocorder knows this, but expects [lat, lng]

  field :yelp_id
  field :twitter_id
  field :facebook_id
  field :googleplus_id

  field :geo_location_history, :type => Array # for mobile crafts like a Food Truck

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
  def geo_point() { latitude:lat, longitude:lng } end
  def geo_point=(latlng_hash) {
    lat   = latlng_hash[:latitude]   if latlng_hash[:latitude].present?
    lat ||= latlng_hash[:lat]        if latlng_hash[:lat].present?

    lng   = latlng_hash[:longitude]  if latlng_hash[:longitude].present?
    lng ||= latlng_hash[:long]       if latlng_hash[:long].present?
    lng ||= latlng_hash[:lng]        if latlng_hash[:lng].present?

    self.lat = lat
    self.lng = lng
  end
  alias_method :geo_coordinate, :geopoint
  alias_method :geo_coordinate=, :geopoint=
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
