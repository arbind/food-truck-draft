class FacebookService < WebCraftService
  include Singleton
  attr_reader :webservice_client

  def self.web_craft_class() FacebookCraft end

  def self.raw_fetch(web_craft_id) # fetch and normalize a web_craft_hash for update_atrributes
    id = "#{web_craft_id}"
    web_craft_hash = client.get_object(id)
  end

  def self.web_fetch(web_craft_id) # fetch and normalize a web_craft_hash for update_atrributes
    web_craft_hash = raw_fetch(web_craft_id)
    
    # do any post process transformations
    website = web_craft_hash['website']
    web_craft_hash['website'] = website.strip.split(' ').first.downcase if website

    web_craft_hash
  end

  # find the website of an account
  def self.website_for_account(user_id_or_url)
    user_id = Web.service_id_from_string_or_href(user_id_or_url, :facebook)
    return nil if user_id.nil?

    web_craft_hash = web_fetch(user_id)
    web_craft_hash['website']
  end 


  # webpage scraping
  def self.hrefs_in_hpricot_doc(doc)
    Web.hrefs_in_hpricot_doc(doc, 'facebook.com', ['data-href', 'href'])
  end

  def self.id_from_href(href)
    return nil if href.nil?
    pagename = nil
    begin
      u = URI.parse(href.downcase)
      u = URI.parse("http://#{href.downcase}") if u.host.nil?
      return nil unless ['www.facebook.com', 'facebook.com'].include?(u.host)
      flat = href.downcase.gsub(/\/\//, '')
      tokens = flat.split('/')
      return nil unless tokens.present?
      case tokens.size
        when 2 # facebook.com/page_id
          pagename = tokens[1] if id_is_valid?(tokens[1])
        when 4 # facebook.com/pages/PageName/page_id  <- use the real page id
          pages = tokens[1].downcase
          page_id = tokens[3]
          pagename = page_id if ( "pages" == pages and id_is_valid?(page_id) )
        else
          # username = nil
      end
    rescue Exception => e
      puts e.message
      puts e.backtrace
    end
    pagename
  end
  # /webpage scraping

  def self.id_is_valid?(id) facebook_username_is_valid?(id) end
  def self.facebook_username_is_valid?(id)
    return false if id.nil?
    id_match = id.match /^[a-z\d.]{5,}$/i 
    id_match.present? and id_match.to_s == id
  end


  private
  def initialize() @webservice_client = Koala::Facebook::API.new end
  def self.client() instance.webservice_client end

end