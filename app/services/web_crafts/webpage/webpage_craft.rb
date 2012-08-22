class WebpageCraft < WebCraft
  # the website's url is aliased to :web_craft_id
  field :host
  field :keywords
  alias_method :url, :web_craft_id
  
end
