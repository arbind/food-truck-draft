class YelpBiz
  include Merge

  attr_accessor :yelp_id
  attr_accessor :yelp_name
  attr_accessor :yelp_phone
  attr_accessor :yelp_image_url

  attr_accessor :yelp_review_count
  attr_accessor :yelp_reviews

  attr_accessor :yelp_rating
  attr_accessor :yelp_rating_img_url        #URL to star rating image for this business (size = 84x17)
  attr_accessor :yelp_rating_img_url_small  #URL to small version of rating image for this business (size = 50x10)
  attr_accessor :yelp_rating_img_url_large  #URL to large version of rating image for this business (size = 166x30)

  attr_accessor :yelp_snippet_text
  attr_accessor :yelp_snippet_image_url

  attr_accessor :yelp_is_claimed
  attr_accessor :yelp_is_closed
  attr_accessor :yelp_url
  attr_accessor :yelp_categories

  def self.materialize_from_yelp_v1(biz_hash)
    self.yelp_id                    = biz_hash['id']                    if biz_hash['id'].present?
    self.yelp_is_claimed            = biz_hash['is_claimed']            if biz_hash['is_claimed'].present?
    self.yelp_is_closed             = biz_hash['is_closed']             if biz_hash['is_closed'].present?
    self.yelp_name                  = biz_hash['name']                  if biz_hash['name'].present?
    self.yelp_mobile_url            = biz_hash['mobile_url']            if biz_hash['mobile_url'].present?
    self.yelp_image_url             = biz_hash['image_url']             if biz_hash['image_url'].present?
    self.yelp_url                   = biz_hash['url']                   if biz_hash['url'].present?
    self.yelp_phone                 = biz_hash['phone']                 if biz_hash['phone'].present?
    self.yelp_review_count          = biz_hash['review_count']          if biz_hash['review_count'].present?
    self.yelp_categories            = biz_hash['categories']            if biz_hash['categories'].present?
    self.yelp_rating                = biz_hash['rating']                if biz_hash['rating'].present?
    self.yelp_rating_img_url        = biz_hash['rating_img_url']        if biz_hash['rating_img_url'].present?
    self.yelp_rating_img_url_small  = biz_hash['rating_img_url_small']  if biz_hash['rating_img_url_small'].present?
    self.yelp_rating_img_url_large  = biz_hash['rating_img_url_large']  if biz_hash['rating_img_url_large'].present?
    self.yelp_snippet_text          = biz_hash['snippet_text']          if biz_hash['snippet_text'].present?
    self.yelp_snippet_image_url     = biz_hash['snippet_image_url']     if biz_hash['snippet_image_url'].present?
  end

  def self.materialize_from_yelp_v2(biz_hash)
    self.yelp_id                    = biz_hash['id']                    if biz_hash['id'].present?
    self.yelp_is_closed             = biz_hash['is_closed']             if biz_hash['is_closed'].present?
    self.yelp_name                  = biz_hash['name']                  if biz_hash['name'].present?
    self.yelp_mobile_url            = biz_hash['mobile_url']            if biz_hash['mobile_url'].present?
    self.yelp_phone                 = biz_hash['phone']                 if biz_hash['phone'].present?
    self.yelp_url                   = biz_hash['url']                   if biz_hash['url'].present?

    self.yelp_image_url             = biz_hash['photo_url']             if biz_hash['photo_url'].present? # *** names deviate
    self.yelp_rating                = biz_hash['avg_rating']            if biz_hash['avg_rating'].present? # *** names deviate

    self.yelp_rating_img_url        = biz_hash['rating_img_url']        if biz_hash['rating_img_url'].present?
    self.yelp_rating_img_url_small  = biz_hash['rating_img_url_small']  if biz_hash['rating_img_url_small'].present?
    self.yelp_rating_img_url_large  = biz_hash['rating_img_url_large']  if biz_hash['rating_img_url_large'].present?

    self.yelp_review_count          = biz_hash['review_count']          if biz_hash['review_count'].present?

    if biz_hash['categories'].present
      categories = biz_hash['categories']
      self.yelp_categories = categories.map {|c| [c['name'], c['category_filter']]}
    end

    if biz_hash['reviews'].present
      reviews = biz_hash['reviews']
      self.yelp_reviews = reviews.map {|r| "review" }
    end


  end

  def self.fetch(yelp_id)
    YelpService.fetch(yelp_id)
  end

  def fetch
    YelpBiz::fetch(yelp_id)
  end

  def pull
    from_source = fetch
    merge!(from_source)
  end

end
