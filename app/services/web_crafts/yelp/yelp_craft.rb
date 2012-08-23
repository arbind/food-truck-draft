class YelpCraft < WebCraft
  field :provider, type: Symbol, default: :yelp

  field :phone
  field :image_url

  field :review_count
  field :reviews

  field :rating
  field :rating_img_url        #URL to star rating image for this business (size = 84x17)
  field :rating_img_url_small  #URL to small version of rating image for this business (size = 50x10)
  field :rating_img_url_large  #URL to large version of rating image for this business (size = 166x30)

  field :snippet_text
  field :snippet_image_url

  field :is_claimed
  field :is_closed
  field :categories
  alias_method :yelp_id, :web_craft_id
  alias_method :url, :href  # yelp specifies href as url=http://www.yelp.com/biz/grill-em-all-los-angeles
  alias_method :url=, :href=

  # aliases for API V2 and V1 backwards compatibility
  alias_method :photo_url, :image_url
  alias_method :photo_url=, :image_url=
  alias_method :avg_rating, :rating
  alias_method :avg_rating=, :rating=

end
