class FlikrCraft
  include Mongoid::Document
  include Mongoid::Timestamps

  field :flickr_id

  field :name
  field :description
  field :location
  field :url
  alias_method :webservice_id, :flickr_id

  def self.materialize_from_flickr(user_hash)
  end

  def self.pull(user_or_page_name) FlickrService.pull(user_or_page_name) end

  def pull() FlickrCraft::pull(flickr_id) end
  
end
