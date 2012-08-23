class FlickrService < WebCraftService
  include Singleton
  attr_reader :webservice_client

  def self.web_fetch(web_craft_id) # fetch and normalize a web_craft_hash for update_atrributes
    webcraft_hash = {} # +++ todo
  end

  # webpage scraping
  def self.hrefs_in_hpricot_doc(doc)
    Web.hrefs_in_hpricot_doc(doc, 'flickr.com')
  end

  def self.id_from_href(href)
    return nil if href.nil?

    flickr_id = nil
    begin
      u = URI.parse(href.downcase)
      u = URI.parse("http://#{href.downcase}") if u.host.nil?
      return nil unless ['www.flickr.com', 'flickr.com'].include?(u.host)
      flat = href.downcase.gsub(/\/\//, '')
      tokens = flat.split('/')
      return nil unless tokens.present?

      case tokens.size
        when 2
          flickr_id = tokens[1] if id_is_valid?(tokens[1])
        when 3
          photos = tokens[1]
          user_id = tokens[2]
          flickr_id = user_id if ("photos" == photos and id_is_valid?(user_id) )
        else
          # flickr_id = nil
      end
    rescue Exception => e
      puts e.message
      puts e.backtrace
    end
    flickr_id
  end

  def self.id_is_valid?(id) flickr_username_is_valid?(id) end
  def self.flickr_username_is_valid?(id)
    return false if id.nil?
    true # +++ create regex for valid flicker user/page names
  end

  # /webpage scraping


  private
  def initialize() @webservice_client = nil end # update with Flickr API client
  def self.client() instance.webservice_client end

end