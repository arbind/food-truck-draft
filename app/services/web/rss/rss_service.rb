class RssService
  include Singleton
  # attr_reader :rss_client  <- add this in once integrated to the API?

  # webpage scraping
  def self.craft_for_href(href)
    id = id_from_href(href)
    craft = pull(id) unless id.nil?
  end
  
  def self.hrefs_in_webpage(url)
    doc = hpricot_doc(url)
    hrefs_in_hpricot_doc(doc)
  end
  def self.hrefs_in_hpricot_doc(doc)
    Web.hrefs_in_hpricot_doc(doc, '/feed')
  end

  def self.id_from_href(href) nil end # rss has no user 
  def self.hash_from_id(id) nil end

  # /webpage scraping


  private

end