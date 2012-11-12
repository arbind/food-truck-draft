class FlickrCraft < WebCraft
  field :provider, type: Symbol, default: :flickr

  embedded_in :craft

  alias_method :flickr_id, :web_craft_id

end
