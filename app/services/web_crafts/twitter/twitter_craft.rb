class TwitterCraft < WebCraft
  field :kind

  field :screen_name
  field :is_protected
  field :twitter_account_created_at

  field :name
  field :description
  field :location
  field :url

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
  alias_method :twitter_id, :web_craft_id
  alias_method :tweet_count, :statuses_count

  def self.web_craft_service_class() TwitterService end

  # def self.materialize(user_hash)
  #   twitter_id = user_hash.delete(:id)
  #   webcraft = TwitterCraft.find_or_initialize_by(web_craft_id: twitter_id)
  #   return nil if webcraft.nil?

  #   #use method chaining to update_attributes
    
  #   user_hash[:is_protected] = user_hash.delete(:protected)
  #   user_hash[:twitter_account_created_at] = user_hash.delete(:created_at)

  #   #remove unneeded atts
  #   user_hash.delete(:status)
  #   user_hash.delete(:id_str)
  #   user_hash.delete(:contributors_enabled)
  #   user_hash.delete(:is_translatorfollowing)
  #   user_hash.delete(:follow_request_sent)
  #   user_hash.delete(:notifications)

  #   image_url = user_hash[:profile_image_url]
  #   user_hash[:profile_image_url_bigger] = image_url # default

  #   # _reasonably_small size seems to be a bigger than the _normal size
  #   bigger_image_url = image_url.gsub(/_normal\./, '_reasonably_small.') if image_url
  #   user_hash[:profile_image_url_bigger] = bigger_image_url if  Web.image_exists?(bigger_image_url)

  #   webcraft.update_attributes(user_hash)
  #   webcraft
  # end

  # def update_timeline(timeline)
  #   self.timeline = timeline.map do |status|
  #     tweet_hash = status.to_hash
  #     tweet_hash[:tweet_id] = tweet_hash.delete(:id);
  #     tweet_hash.delete(:user)
  #     tweet_hash
  #   end
  #   save!
  # end

  # def self.pull(screen_name) TwitterService.pull(screen_name) end

  # def pull() TwitterCraft::pull(screen_name) end
  
end
