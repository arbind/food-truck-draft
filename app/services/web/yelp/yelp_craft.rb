class YelpCraft
  include Mongoid::Document
  include Mongoid::Timestamps

  field :yelp_id
  field :name
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
  field :url
  field :categories
  alias_method :webservice_id, :yelp_id

  # aliases for API V2 and V1 backwards compatibility
  alias_method :photo_url, :image_url
  alias_method :photo_url=, :image_url=
  alias_method :avg_rating, :rating
  alias_method :avg_rating=, :rating=

  def self.materialize_from_V1_API(biz_hash)
    # pull id out so it doesn't clobber object is
    yelp_id = biz_hash['yelp_id'] = biz_hash.delete('id')
    biz = YelpCraft.find_or_initialize_by(yelp_id: yelp_id)

    # also remove any unneeded atts from biz_hash
    biz.update_attributes(biz_hash)
    biz
  end

  def self.materialize_from_V2_API(biz_hash)
    # pull id out so it doesn't clobber object is
    yelp_id = biz_hash['yelp_id'] = biz_hash.delete('id')
    biz = YelpCraft.find_or_initialize_by(yelp_id: yelp_id)

    # if biz_hash['categories'].present? # flatten out yelp's category stuff
    #   categories = biz_hash.delete('categories')
    #   biz_hash['categories'] = categories.map {|c| [c['name'], c['category_filter']]}
    # end

    # if biz_hash['reviews'].present?
    #   reviews = biz_hash.delete('reviews')
    #   biz_hash['reviews'] = reviews.map {|r| "review" }
    # end

    # also remove any unneeded atts from biz_hash
    biz.update_attributes(biz_hash)
    biz
  end

  def self.fetch(yelp_id)
    YelpService.fetch(yelp_id)
  end

  def fetch
    YelpCraft::fetch(yelp_id)
  end

  def pull
    from_source = fetch
    merge!(from_source)
  end

end
