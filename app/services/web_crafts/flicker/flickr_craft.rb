class FlickrCraft < WebCraft
  field :provider, type: Symbol, default: :flickr

  alias_method :flickr_id, :web_craft_id

end
