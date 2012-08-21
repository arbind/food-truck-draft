class RssService < WebCraftService
  include Singleton
  attr_reader :webservice_client

  # def self.web_craft_class() RssCraft end

  # webpage scraping
  def self.hrefs_in_hpricot_doc(doc)
    Web.hrefs_in_hpricot_doc(doc, '/feed')
  end
  # /webpage scraping


  private
  def initialize() @webservice_client = nil end # update with API client
  def self.client() instance.webservice_client end

end