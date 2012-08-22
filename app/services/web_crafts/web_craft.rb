class WebCraft
  include Mongoid::Document
  include Mongoid::Timestamps
  field :web_craft_id, index: true

  field :name
  field :description
  field :location
  field :username, index: true
  field :href, index: true

  # field :id_tags, index: true # e.g. facebook_id, yelp_id, twitter_id etc. should be aliased to this field for a normalized id 
  # field :username_tags, index: true  # e.g. username, twitter_handle
  
  field :href_tags, type: Array, default: [], index: true
  field :search_tags, type: Array, default: [], index: true

  belongs_to :craft
  alias_method :user_name, :username
  alias_method :user_name=, :username=
  alias_method :screen_name, :username
  alias_method :screen_name=, :username=
  alias_method :link, :href
  alias_method :link=, :href=
  alias_method :url, :href
  alias_method :url=, :href=
  alias_method :about, :description
  alias_method :about=, :description=

  # convert classname to provider name: e.g. TwitterCraft -> :twitter
  def self.provider() name[0..-6].symbolize end
  def self.provider_key() name[0..-6].downcase end

  # get the service class for this craft: e.g. TwitterCraft -> TwitterService
  def self.web_craft_service_class() @@web_craft_service_class ||= Kernel.const_get("#{name[0..-6]}Service") end

  def self.materialize(web_craft_hash)
    wc_id = web_craft_hash[:web_craft_id] || web_craft_hash['web_craft_id']
    return nil if wc_id.nil?

puts "finding webcraft for class: #{name}!!!!!!!!!!!!!!!!!!!!!!"
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

end
