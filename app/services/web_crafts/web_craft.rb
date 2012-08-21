class WebCraft
  include Mongoid::Document
  include Mongoid::Timestamps

  field :web_craft_id # e.g. facebook_id, yelp_id, twitter_id etc. should be aliased to this field for a normalized id 
  field :search_tags, type: Array, default: [], index: true 

  belongs_to :craft

  def self.web_craft_service_class() raise "#{name}.#{__method__} subclass hook not implemented!" end
  # def self.materialize(web_craft_hash) raise "#{name}.#{__method__} subclass hook not implemented!" end

  def self.materialize(web_craft_hash)
    web_craft_id = web_craft_hash[:web_craft_id] || web_craft_hash['web_craft_id']
    return nil if web_craft_id.nil?

puts "finding webcraft for class: #{name}!!!!!!!!!!!!!!!!!!!!!!"
    web_craft = find_or_initialize_by(web_craft_id: web_craft_id)
    web_craft.update_attributes(web_craft_hash) if web_craft

    web_craft
  end

  # fetch and pull
  def self.fetch(web_craft_id) web_craft_service_class.fetch(web_craft_id) end
  def self.pull(web_craft_id) web_craft_service_class.pull(web_craft_id) end
  # /fetch and pull

  def fetch() web_craft_service_class.fetch (web_craft_id) end
  def pull
    web_craft_hash = web_craft_service_class.fetch (web_craft_id)
    update_attributes(web_craft_hash)
  end

end
