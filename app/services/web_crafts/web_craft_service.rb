class WebCraftService

  def self.web_craft_class() raise "#{name}.#{__method__} subclass hook not implemented!" end

  def self.web_fetch(web_craft_id) # fetch and normalize a web_craft_hash for update_atrributes
    raise "#{name}.#{__method__} subclass hook not implemented!"
  end

  # fetch and pull
  def self.fetch(web_craft_id)
    begin
      web_craft_hash = web_fetch(web_craft_id)
      return nil if web_craft_hash.nil?

      if web_craft_hash[:web_craft_id].nil?
        id = web_craft_hash.delete('id') || web_craft_hash.delete(:id)
        web_craft_hash[:web_craft_id] = id
      end
      # grab location info if we can
      if (web_craft_hash['location'].present? and web_craft_hash['location'].kind_of? Hash)
        l_hash = {}
        l = web_craft_hash.delete('location')
        l_hash[:address] = l[:address] || l['address']
        if l_hash[:address].present?
          a = l_hash[:address]
          a = *a # proceses address as an array incase addresss is an array for street 1, 2
          l_hash[:address] = a.join(', ') 
        end
        l_hash[:city] = l[:city] || l['city']
        l_hash[:state] = l[:state_code] || l['state_code'] || l[:state] || l['state']
        l_hash[:zip] = l[:zip] || l['zip'] || l[:zipcode] || l['zipcode'] || l[:postal_code] || l['postal_code']
        l_hash[:country] = l[:country] || l['country']
        web_craft_hash[:location_hash] = l_hash
      end

      # protect mongoid object created_at and updated_at fields
      prefix = web_craft_class.name.downcase
      web_craft_hash[:"#{prefix}_created_at"] = web_craft_hash.delete(:created_at)
      web_craft_hash[:"#{prefix}_updated_at"] = web_craft_hash.delete(:updated_at)

      # do any post process transformations

      web_craft_hash
    rescue Exception => e
      puts e.message
      puts e.backtrace
      return nil
    end
  end

  def self.pull(web_craft_id)
    begin
      web_craft_hash = fetch(web_craft_id)
      web_craft = web_craft_class.materialize(web_craft_hash) if web_craft_hash
      web_craft
    rescue Exception => e 
      puts e.message
      puts e.backtrace
      nil
    end
  end
  # /fetch and pull

  # webpage scraping
  def self.web_craft_for_href(href)
    id = id_from_href(href)
    puts "id = #{id}"
    craft = pull(id) unless id.nil?
  end

  def self.hrefs_in_webpage(url)
    doc = hpricot_doc(url)
    hrefs_in_hpricot_doc(doc)
  end

  def self.hrefs_in_hpricot_doc(doc) raise "#{name}.#{__method__} subclass hook not implemented!" end
  def self.id_from_href(href) raise "#{name}.#{__method__} subclass hook not implemented!" end
  # /webpage scraping

  # api calls to get hash
  def self.hash_from_id(id) raise "#{name}.#{__method__} subclass hook not implemented!" end

  private
  def initialize() end

end