class WebpageCraft < WebCraft
  # the website's url is aliased to :web_craft_id
  field :host
  field :name
  field :title
  field :description
  field :keywords
  alias_method :url, :web_craft_id

  def self.web_craft_service_class() WebpageService end
  
end
