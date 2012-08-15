class Location
  include ToHash
  extend AttrAlias

  attr_accessor :geo_point
  attr_alias    :geo_coordinate, :geo_point

  attr_accessor :geo_boundary
  attr_alias    :bounding_box, :geo_boundary

  attr_accessor :address
  attr_accessor :street_address, :address

  attr_accessor :city

  attr_accessor :state
  attr_alias    :st, :state

  attr_accessor :zipcode
  attr_alias    :zip, :zipcode
  attr_alias    :postal_code, :zipcode

  attr_accessor :metro

  attr_accessor :neighborhoods

  attr_accessor :country
  attr_alias    :country_code, :country


  def initialize(settings = {})
    self.address        = settings[:address] if settings[:address].present?
    self.city           = settings[:city] if settings[:city].present?
    self.state          = settings[:state] if settings[:state].present?
    self.zipcode        = settings[:zipcode] if settings[:zipcode].present?
    self.zip          ||= settings[:zip] if settings[:zip].present?
    self.neighborhoods  = settings[:neighborhood] if settings[:neighborhood].present?
    self.metro          = settings[:metro] if settings[:metro].present?
    self.country        = settings[:country] if settings[:country].present?

    self.geo_point      = GeoPoint::materialize(settings)
    self.geo_boundary   = GeoBoundary.materialize(settings)
  end
  def bounding_box() 
    return geo_boundary.to_hash if geo_boundary.present? and geo_boundary.nw.present?
    {bounding_box_error: 'No top left geo point!'}
  end

  def radius() 
    return geo_boundary.radius if geo_boundary.present? and geo_boundary.radius.present?
    0
  end


  def address_to_s
    a = []
    a << address if address.present?
    a << neighborhoods.first if neighborhoods.present?
    a << city if city.present?
    a << metro if (city.nil? and metro.present?)
    a << state if state.present?
    a << zipcode if zipcode.present?
    a << country if country.present?
    a.join(',')
  end

  def mailing_address
    a = {}
    a[:address]       = address if address.present?
    a[:city]          = city if city.present?
    a[:state]         = state if state.present?
    a[:zipcode]       = zipcode if zipcode.present?
    a[:metro]         = metro if metro.present?
    a[:country]       = country if country.present?
    a[:radius]        = radius if radius > 0
    a[:neighborhoods] = neighborhoods if neighborhoods.present?
    a
  end

  def to_hash
    h = mailing_address
    h.merge!(geo_point.to_hash) if geo_point.present?
    h.merge!(geo_boundary.to_hash) if geo_boundary.present?
    h
  end

end

