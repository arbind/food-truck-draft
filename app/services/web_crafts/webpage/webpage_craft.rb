class WebpageCraft < WebCraft
  field :provider, type: Symbol, default: :webpage

  field :host
  field :keywords

  embedded_in :craft

  alias_method :url, :web_craft_id   # use the website's url as its :web_craft_id
  
end
