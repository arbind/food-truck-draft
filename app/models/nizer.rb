class Nizer
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid

  field :kind, type: Symbol # lowercased and underscored - e.g.  :yo_yo instead of :"Yo Yo"
  field :name, type: String # downcased - e.g.  "santa monica" instead of "Santa Monica"

  field :approved, type: Boolean, default: false

  field :address, default: nil
  field :coordinates, :type => Array, default: [nil, nil] 

  has_and_belongs_to_many :crafts

  has_and_belongs_to_many :nizers, :class_name => 'Nizer', :inverse_of => :parents
  has_and_belongs_to_many :parents, :class_name => 'Nizer', :inverse_of => :nizers

  # some handy scopes
  scope :ok, where(approved: true)
  scope :approved, where(approved: true)

  scope :not_ok, where(approved: false)
  scope :unapproved, where(approved: false)

  scope :roots, where(:parent_ids.size => 0)

  scope :categories, where(kind: :category)

  scope :tags, where(kind: :tag)
  scope :keywords, where(kind: :keyword)

  scope :colleges, where(kind: :edu)
  scope :cities, where(kind: :city)
  scope :states, where(kind: :state)
  scope :metros, where(kind: :metro)
  scope :counties, where(kind: :county)
  scope :neighborhoods, where(kind: :neighborhood)
  scope :countries, where(kind: :country)

  scope :meals, where(kind: :meal)
  scope :cuisines, where(kind: :cuisine)
  scope :festivals, where(kind: :festival)

  index({ kind: 1, name: 1 }, { unique: true, name: "kind_name_index" })
  # index({ geo_point: "2d" }, { min: -200, max: 200 })

  # geocoder hooks
  geocoded_by :address                    # can also be an IP address
  reverse_geocoded_by :coordinates
  before_save :geocode_locations     # auto-fetch geo coordinates

  before_validation :format_fields        # symbolize and lowercase


  # factory methods
  def self.materialize(name, knd) Nizer.find_or_create_by(name: name.downcase, kind: knd.symbolize) end

  def self.materialize_meal(name) materialize(name, :meal) end
  def self.materialize_cuisine(name) materialize(name, :cuisine) end

  def self.materialize_tag(name) materialize(name, :tag) end
  def self.materialize_keyword(name) materialize(name, :keyword) end
  def self.materialize_category(name) materialize(name, :category) end

  def self.materialize_country(name) materialize(name, :country) end
  # /factory methods


  # scopes on children
  def ok() nizers.ok end
  def not_ok() nizers.not_ok end

  def subcategories() nizers.categories end

  def colleges() nizers.colleges end
  def cities() nizers.cities end
  def states() nizers.states end
  def metros() nizers.metros end
  def counties() nizers.counties end
  def neighborhoods() nizers.neighborhoods end
  def festivals() nizers.festivals end
  # /scopes on children

  # add to children
  def add(name, knd)
    nizers.find_or_create_by(name: name.downcase, kind: knd.symbolize)
    save!
  end

  def add_subcategory(name)
    return nil if name.nil?
    raise "A subcategory can only be added to a category!" if :category != kind
    add(name, :category)
  end

  def add_festival(name)
    return nil if name.nil?
    raise "A festival can only be added to a location!" unless (:country!= kind or :state != kind or :city != kind or :metro != kind or :county != kind or :neighborhood != kind)
    add(name, :category)
  end


  def add_state(name)
    return nil if name.nil?
    raise "A state can only be added to a country!" if :country != kind
    add(name, :state)
  end

  def add_college(name)
    return nil if name.nil?
    raise "A college can only be added to a city!" if :city != kind
    add(name, :edu)
  end

  def add_city(name)
    return nil if name.nil?
    raise "A city can only be added to a state!" if :state != kind
    add(name, :city)
  end

  def add_metro(name)
    return nil if name.nil?
    raise "A metro can only be added to a state!" if :state != kind
    add(name, :metro)
  end

  def add_county(name)
    return nil if name.nil?
    raise "A county can only be added to a state!" if :state != kind
    add(name, :county)
  end

  def add_neighborhood(name)
    return nil if name.nil?
    raise "A neighborhood can only be added to a state!" if :state != kind
    add(name, :neighborhood)
  end
  # /add to children

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
  def format_fields
    self.kind = kind.downcase.symbolize
    self.name = name.to_s.downcase
  end

  def geocode_locations
    return true unless (:city===kind or :state===kind or :metro===kind or :country===kind)
    addr = address

    if (:city === kind or :metro === kind or :county === kind) #  city/metro or county name
      addr = "#{name}"  # create a new string, so that we do not modify the name field
      state = parents.states.first
      if state.present?
        addr << ", #{state.name}"
        country = state.parents.countries.first
        if country.present?
          addr << ", #{country.name}"
        end
      end
    elsif :state === kind
      addr = "#{name}"
      country = parents.countries.first
      if country.present?
        addr << ", #{country.name}"
      end
    elsif :country === kind
      addr  = name
    end

    self.address = addr

    geocode if changes[:address].present?
    return true
  end

end
