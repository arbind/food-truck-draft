module GeoCoordinateAliases

  def latitude() coordinates.last end
  alias_method :lat, :latitude

  def latitude=(lat) coordinates ||= [0,0]; coordinates[1] = lat end
  alias_method :lat=, :latitude=


  def longitude() coordinates.first end
  alias_method :lng, :longitude
  alias_method :long, :longitude

  def longitude=(lng) coordinates[0] = lng end
  alias_method :lng=, :longitude=
  alias_method :long=, :longitude=
  # /geocoding  aliases

  # geo point hash representation
  def geo_point() [latitude:lat, longitude:lng] end
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
end