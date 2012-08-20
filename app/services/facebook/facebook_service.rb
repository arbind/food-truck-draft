class FacebookService
  include Singleton
  # attr_reader :facebook_client <- add this in once integrated with the API

  def self.pull(user_or_page_name)
    begin
puts 1
      graph = Koala::Facebook::API.new
puts 2
      user_hash = graph.get_object("#{user_or_page_name}")
puts 3
      return nil if user_hash.nil?

      # create or updates the presence
puts 4
      presence = FacebookCraft.materialize_from_facebook(user_hash)
puts 5
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
      # return nil
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
  def initialize()  end

end