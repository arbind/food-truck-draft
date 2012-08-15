class GeoPoint
  include ToHash
  extend AttrAlias

  attr_accessor :latitude
  attr_alias :lat, :latitude

  attr_accessor :longitude
  attr_alias :lng, :longitude
  attr_alias :long, :longitude

  def self.materialize(settings)
    GeoPoint.new(settings) if (settings[:atitude].present? or settings[:lat].present?)
  end

  def initialize(settings = {})
    self.latitude   = settings[:latitude]   if settings[:latitude].present?
    self.lat      ||= settings[:lat]        if settings[:lat].present?

    self.longitude  = settings[:longitude]  if settings[:longitude].present?
    self.lng      ||= settings[:lng]        if settings[:lng].present?
    self.long     ||= settings[:long]       if settings[:long].present?
  end

end