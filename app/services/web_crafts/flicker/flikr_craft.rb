class FlikrCraft < WebCraft
  field :name
  field :description
  field :location
  field :url
  alias_method :flickr_id, :web_craft_id

  def self.web_craft_service_class() FlickrService end
  
end
