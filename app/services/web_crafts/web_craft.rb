class WebCraft
  include Mongoid::Document
  include Mongoid::Timestamps
  field :web_craft_id, index: true

  field :name
  field :description
  field :website
  field :location
  field :username, index: true
  field :href, index: true

  # field :id_tags, index: true # e.g. facebook_id, yelp_id, twitter_id etc. should be aliased to this field for a normalized id 
  # field :username_tags, index: true  # e.g. username, twitter_handle
  
  field :href_tags, type: Array, default: [], index: true
  field :search_tags, type: Array, default: [], index: true

  belongs_to :craft
  
  scope :yelp_crafts,     where(provider: :yelp)
  scope :flickr_crafts,   where(provider: :flickr)
  scope :webpage_crafts,  where(provider: :webpage)
  scope :twitter_crafts,  where(provider: :twitter)
  scope :facebook_crafts, where(provider: :facebook)
  scope :you_tube_crafts, where(provider: :you_tube)

  alias_method :user_name, :username
  alias_method :user_name=, :username=

  before_save :format_attributes

  # convert classname to provider name: e.g. TwitterCraft -> :twitter
  def self.provider() name[0..-6].symbolize end
  def self.provider_key() name[0..-6].downcase end

  # get the service class for this craft: e.g. TwitterCraft -> TwitterService
  def self.web_craft_service_class() @@web_craft_service_class ||= Kernel.const_get("#{name[0..-6]}Service") end

  def self.materialize(web_craft_hash)
    wc_id = web_craft_hash[:web_craft_id] || web_craft_hash['web_craft_id']
    return nil if wc_id.nil?

    web_craft = find_or_initialize_by(web_craft_id: wc_id)
    web_craft.update_attributes(web_craft_hash) if web_craft

    web_craft
  end

  # fetch and pull
  def self.fetch(web_craft_id) web_craft_service_class.fetch(web_craft_id) end
  def self.pull(web_craft_id) web_craft_service_class.pull(web_craft_id) end
  # /fetch and pull

  def provider() self.class.provider end
  def provider_key() self.class.provider_key end

  def fetch() web_craft_service_class.fetch(web_craft_id) end
  def pull
    web_craft_hash = web_craft_service_class.fetch(web_craft_id)
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
    self.website = website.downcase.urlify! unless website.nil?
    self.href = href.downcase.urlify! unless website.nil?
  end
end
