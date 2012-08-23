class FacebookCraft < WebCraft
  field :provider, type: Symbol, default: :facebook

  field :likes
  field :talking_about_count

  field :first_name
  field :last_name
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
  field :cover
  alias_method :facebook_id, :web_craft_id
  # normalize attributes for WebCraft
  alias_method :link, :href  # facebook specifies it href as link=
  alias_method :link=, :href=
  alias_method :about, :description
  alias_method :about=, :description=

  def self.provider_key() 'fb' end
  
end
