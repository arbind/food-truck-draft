class WebpageService < WebCraftService
  include Singleton
  attr_reader :webservice_client

  def self.web_craft_class() WebpageCraft end

  def self.web_fetch(web_craft_id) # fetch and normalize a web_craft_hash for update_atrributes
    web_craft_hash = {
      web_craft_id: web_craft_id,
      name: nil, # web page title
      description: nil,
      keywords: nil
    }
    # +++ todo
    web_craft_hash
  end

  # webpage scraping
  def self.id_from_href(href) href  end # href is the id
  # /webpage scraping

private
  def initialize() @webservice_client = nil end
  def self.client() instance.webservice_client end
  def self.id_is_valid?(id) true end

end