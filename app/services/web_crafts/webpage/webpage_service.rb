class WebpageService < WebCraftService
  include Singleton
  attr_reader :webservice_client

  def self.web_craft_class() WebpageCraft end

  def self.fetch_remote_web_craft_hash(web_craft_id) # fetch and normalize a web_craft_hash for update_atrributes
    webcraft_hash = { web_craft_id: web_craft_id }
    # +++ todo
    webcraft_hash
  end

  # webpage scraping
  def self.id_from_href(href) href  end # href is the id
  # /webpage scraping

private
  def initialize() @webservice_client = nil end
  def self.client() instance.webservice_client end
  def self.id_is_valid?(id) true end

end