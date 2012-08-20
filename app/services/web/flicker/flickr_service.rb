class FlickrService
  include Singleton
  # attr_reader :flickr_client  <- add this in once integrated to the API?

  def self.pull(user_or_page_name)
    begin
      user_hash = {}
      return nil if user_hash.nil?

      # create or updates the presence
      presence = FlickrCraft.materialize_from_facebook(user_hash)
      return presence
    rescue Exception => e 
      puts e.message
      return nil
    end
  end

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
      # return nil
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
  def initialize()  end

end