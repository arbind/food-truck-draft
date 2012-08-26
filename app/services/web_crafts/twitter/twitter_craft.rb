class TwitterCraft < WebCraft
  field :provider, type: Symbol, default: :twitter

  field :is_protected
  field :twitter_account_created_at

  field :followers_count
  field :friends_count
  field :listed_count
  field :favourites_count
  field :utc_offset
  field :time_zone
  field :geo_enabled
  field :verified
  field :statuses_count
  field :lang
  field :profile_background_color
  field :profile_background_image_url
  field :profile_background_image_url_https
  field :profile_background_tile
  field :profile_image_url
  field :profile_image_url_bigger
  field :profile_image_url_https
  field :profile_link_color
  field :profile_sidebar_border_color
  field :profile_sidebar_fill_color
  field :profile_text_color
  field :profile_use_background_image
  field :default_profile
  field :default_profile_image

  field :timeline, default: []
  field :oembed, type: Hash, default: {}
  
  alias_method :twitter_id, :web_craft_id
  alias_method :twitter_id=, :web_craft_id=
  # normalize attributes to WebCraft 
  alias_method :url, :website  # twitter specifies website as url=
  alias_method :url=, :website=
  alias_method :screen_name, :username # twitter uses screen_name for username
  alias_method :screen_name=, :username=
  # convenience aliases
  alias_method :tweet_count, :statuses_count
  alias_method :tweet_count=, :statuses_count=
  alias_method :protected, :is_protected
  alias_method :protected=, :is_protected=

  def self.provider_key() '@' end

end
