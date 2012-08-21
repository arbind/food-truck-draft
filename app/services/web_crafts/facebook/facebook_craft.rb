class FacebookCraft < WebCraft
  field :likes
  field :talking_about_count

  field :name
  field :first_name
  field :last_name
  field :username
  field :gender
  field :locale
  field :is_published
  field :website
  field :about
  field :location
  field :parking
  field :public_transit
  field :payment_options
  field :culinary_team
  field :general_manager
  field :restaurant_services
  field :restaurant_specialties
  field :category
  field :link
  field :cover
  alias_method :facebook_id, :web_craft_id

  def self.web_craft_service_class() FacebookService end

  # def self.materialize(user_hash)
  #   facebook_id = user_hash.delete('id')
  #   webcraft = FacebookCraft.find_or_initialize_by(web_craft_id: facebook_id)
  #   return nil if webcraft.nil?
  #   #remove unneeded atts
  #   # image_url = user_hash[:profile_image_url]
  #   # user_hash[:profile_image_url_bigger] = image_url # default

  #   webcraft.update_attributes(user_hash)
  #   webcraft

  # end

  # def self.pull(user_or_page_name) FacebookService.pull(user_or_page_name) end

  # def pull() FacebookCraft::pull(facebook_id) end
  
end
