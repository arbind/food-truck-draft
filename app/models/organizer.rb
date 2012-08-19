class Organizer
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid

  field :address, default: nil
  field :coordinates, :type => Array, default: [nil, nil] 

  field :kind, type: Symbol
  field :name, type: String

  field :approved, type: Boolean, default: false

  has_and_belongs_to_many :crafts

  has_and_belongs_to_many :organizers, :class_name => 'Organizer', :inverse_of => :parents
  has_and_belongs_to_many :parents, :class_name => 'Organizer', :inverse_of => :organizers

  index({ kind: 1, name: 1 }, { unique: true, name: "kind_name_index" })
  # index({ geo_point: "2d" }, { min: -200, max: 200 })

  geocoded_by :address                    # can also be an IP address
  reverse_geocoded_by :coordinates
  after_validation :geocode_this_location # auto-fetch coordinates

  def geocode_this_location
    return true unless (:city===kind or :state===kind or :metro===kind or :country===kind)
    city = nil
    state = nil
    country = nil
    if (:city === kind or :metro === kind)
      city = name
      s = parents.where(kind: :state)
      state = s.name if s.present?
      c = parents.where(kind: :country)
      country = c.name if c.present?
    end
    if :state === kind
      state = name
    end
    if :country === kind
      country = name
    end
    addr = ""
    addr << city if city.present?
    addr << ", " if city.present? and (state.present? or country.present?)
    addr << ",#{state}" if state.present?
    addr << ", " if (state.present? and country.present?)
    addr << country if country.present?

    self.address =addr

    geocode if changes[:address].present?
    return true
  end

  def add(organizer)
    organizers.push(organizer)
    organizer.save
    save
  end

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

end
