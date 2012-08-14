class Location
  include ToHash
  attr_accessor :address, :city, :state, :zipcode, :neighborhood, :metro, :country
  attr_accessor :latitude, :longitude,

  attr_accessor :radius
  attr_accessor :bottom_right_latitude, :bottom_right_longitude, :top_left_latitude, :top_left_longitude 

  def initialize(settings = {})

    self.radius       = settings[:radius] || 2
    
    self.address      = settings[:address] if settings[:address].present?
    self.city         = settings[:city] if settings[:city].present?
    self.state        = settings[:state] if settings[:state].present?
    self.zipcode      = settings[:zipcode] if settings[:zipcode].present?
    self.neighborhood = settings[:neighborhood] if settings[:neighborhood].present?
    self.metro        = settings[:metro] if settings[:metro].present?
    self.country      = settings[:country] if settings[:country].present?

    self.latitude     = settings[:latitude] if settings[:latitude].present?
    self.longitude    = settings[:longitude] if settings[:longitude].present?

    self.bottom_right_latitude =   settings[:bottom_right_latitude] if settings[:bottom_right_latitude].present?
    self.bottom_right_longitude =  settings[:bottom_right_longitude] if settings[:bottom_right_longitude].present?
    self.top_left_latitude =       settings[:top_left_latitude] if settings[:top_left_latitude].present?
    self.top_left_longitude =      settings[:top_left_longitude] if settings[:top_left_longitude].present?
  end

  def geo_point
    {
      latitude: latitude,
      longitude: longitude,
      radius: radius
    }
  end

  def mailing_address
    {
      address: address,
      city: city,
      state: state,
      zipcode: zipcode,
      neighborhood: neighborhood,
      metro: metro,
      country: country,
      radius: radius
    }
  end

  def bounding_box
    { 
      bottom_right_latitude:  bottom_right_latitude,
      bottom_right_longitude: bottom_right_longitude,
      top_left_latitude:      top_left_latitude,
      top_left_longitude:     top_left_longitude,
      radius: radius
    }
  end
end