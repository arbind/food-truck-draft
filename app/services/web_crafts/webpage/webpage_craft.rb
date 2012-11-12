class WebpageCraft < WebCraft
  # the website's url is aliased to :web_craft_id
  field :host
  field :keywords

  embedded_in :craft

  alias_method :url, :web_craft_id
  
end
