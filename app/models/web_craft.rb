class WebCraft
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid

  field :web_craft_id
  field :href # url to this provider's account
  field :username

  field :name
  field :description
  field :website # url to craft's actual website

  field :location_hash
  field :address, default: nil
  field :coordinates, type: Array, default: [] # does geocoder gem auto index this?

  # field :id_tags, index: true # e.g. facebook_id, yelp_id, twitter_id etc. should be aliased to this field for a normalized id 
  # field :username_tags, index: true  # e.g. username, twitter_handle

  field :href_tags, type: Array, default: []
  field :search_tags, type: Array, default: []

  belongs_to :craft

  index :web_craft_id
  index :username
  index :href_tags
  index :search_tags


  scope :yelp_crafts,     where(provider: :yelp)
  scope :flickr_crafts,   where(provider: :flickr)
  scope :webpage_crafts,  where(provider: :webpage)
  scope :twitter_crafts,  where(provider: :twitter)
  scope :facebook_crafts, where(provider: :facebook)
  scope :you_tube_crafts, where(provider: :you_tube)
  scope :google_plus_crafts, where(provider: :google_plus)

  geocoded_by :address
  reverse_geocoded_by :coordinates

  alias_method :user_name, :username
  alias_method :user_name=, :username=

  before_save :format_attributes
  before_save :geocode_this_location! # auto-fetch coordinates

  # convert classname to provider name: e.g. TwitterCraft -> :twitter
  def self.provider() name[0..-6].symbolize end
  def self.provider_key() name[0..-6].downcase end

  # get the service class for this craft: e.g. TwitterCraft -> TwitterService
  def self.web_craft_service_class() @@web_craft_service_class ||= Kernel.const_get("#{name[0..-6]}Service") end
  def web_craft_service_class() self.class.web_craft_service_class end

  def self.materialize(web_craft_hash)
    wc_id = web_craft_hash[:web_craft_id] || web_craft_hash['web_craft_id']
    return nil if wc_id.nil?

    web_craft = find_or_initialize_by(web_craft_id: "#{wc_id}")
    web_craft.update_attributes(web_craft_hash) if web_craft

    web_craft
  end

  # fetch and pull
  def self.fetch(web_craft_id) web_craft_service_class.fetch(web_craft_id) end
  def self.pull(web_craft_id) web_craft_service_class.pull(web_craft_id) end
  # /fetch and pull

  def provider() self.class.provider end
  def provider_key() self.class.provider_key end

  def id_for_fetching() web_craft_id end
  def fetch() web_craft_service_class.fetch(web_craft_id) end
  def pull
    web_craft_hash = web_craft_service_class.fetch(id_for_fetching)
    calculate_tags!(web_craft_hash)
    update_attributes(web_craft_hash)
  end

  def calculate_tags!(web_craft_hash)
    calculate_href_tags!(web_craft_hash)
    calculate_search_tags!(web_craft_hash)
  end

  def calculate_href_tags!(web_craft_hash)
    web_craft_hash[:href_tags] = []
  end
  def calculate_search_tags!(web_craft_hash)
    web_craft_hash[:search_tags] = []
  end

  private
  def format_attributes
    self.web_craft_id = "#{web_craft_id}" unless web_craft_id.kind_of? String
    # urlify
    self.website = website.downcase.urlify! if website.looks_like_url?
    self.href = href.downcase.urlify! if href.looks_like_url?
  end

  def geocode_this_location!
    puts "changes[:address].present? : #{changes[:address].present?}"

    if self.lat.present? and (new? or changes[:coordinates].present?)
      puts "coordinates changed!"
      reverse_geocode # udate the address
      # +++ add {time, coordinates, address} to geo_location_history
    elsif location_hash.present? and not self.lat.present? and (new? or changes[:location_hash].present?)
      puts "location_hash changed!"
      l = []
      (l << location_hash[:address]) if location_hash[:address].present?
      (l << location_hash[:city]) if location_hash[:city].present?
      (l << location_hash[:state]) if location_hash[:state].present?
      (l << location_hash[:zip]) if location_hash[:zip].present?
      (l << location_hash[:country]) if location_hash[:country].present?
      self.address = l.join(', ') if l.present?
      geocode # update lat, lng
    end
    return true
  end

  include GeoCoordinateAliases
end
