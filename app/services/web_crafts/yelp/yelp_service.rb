class YelpService < WebCraftService
  include Singleton
  attr_reader :webservice_client

  V2_MAX_RESULTS_LIMIT = 20
  V2_MAX_RADIUS_FILTER = 40000 #in meters (~25 miles)

  def self.web_craft_class() YelpCraft end

  def self.raw_fetch(web_craft_id)
    phone_number = phone_number_10_digits(web_craft_id)
    if phone_number
      web_craft_hash = biz_for_phone_number(phone_number)
    else
      web_craft_hash = biz_for_id(web_craft_id)
    end
  end

  def self.web_fetch(web_craft_id)
    web_craft_hash = raw_fetch(web_craft_id)
    return nil if web_craft_hash.nil?
    # normalize attributes
    # +++ todo check if host is yelp, if so, set href - else set website?
    web_craft_hash['href'] = web_craft_hash.delete('url') 

    # +++ todo
    # if web_craft_hash['categories'].present? # flatten out yelp's category stuff
    #   categories = web_craft_hash.delete('categories')
    #   web_craft_hash['categories'] = categories.map {|c| [c['name'], c['category_filter']]}
    # end

    # +++ todo
    # if web_craft_hash['reviews'].present?
    #   reviews = web_craft_hash.delete('reviews')
    #   web_craft_hash['reviews'] = reviews.map {|r| "review" }
    # end

    web_craft_hash
  end


  # webpage scraping
  def self.hrefs_in_hpricot_doc(doc)
    Web.hrefs_in_hpricot_doc(doc, 'yelp.com')
  end

  def self.id_from_href(href)
    return nil if href.nil?

    listing_id = nil
    begin
      u = URI.parse(href.downcase)
      u = URI.parse("http://#{href.downcase}") if u.host.nil?
      return nil unless ['www.yelp.com', 'yelp.com'].include?(u.host)
      flat = href.downcase.gsub(/\/\//, '')
      tokens = flat.split('/')
      return nil unless tokens.present?

      case tokens.size
        when 3
          biz = tokens[1]
          user_id = tokens[2]
          listing_id = user_id if ("biz" == biz and id_is_valid?(user_id) )
        else
          # listing_id = nil
      end
    rescue Exception => e
      puts e.message
      puts e.backtrace
    end
    listing_id
  end

  def self.id_is_valid?(id) yelp_username_is_valid?(id) end

  def self.yelp_username_is_valid?(id)
    return false if id.nil?
    true # +++ create regex for valid flicker user/page names
  end
  # /webpage scraping


  # Yelp API Integration

  # V2 Yelp API calls
  def self.biz_for_id(yelp_id)
    query = v2({yelp_business_id: yelp_id})
    request = Yelp::V2::Business::Request::Id.new(query)
    response = client.search(request)
  end

  def self.biz_for_phone_number(number)
    # there is no phone number search in v2, lets use v1
    response = self.v1_biz_for_phone_number(number) # a v1 response
    if response
      # v1 and v2 yelp id's do not match
      # but we can use the v2 search with v1 yelp id to get the correct v2 version
      # (don't want the same biz in our cache with two times = each with different yelp_ids!)
      v1_yelp_id = response['id'] # v1 yelp_id = '53UyLtU4F7seRkPfL6TY6Q'
      response = biz_for_id(v1_yelp_id) if v1_yelp_id # a v2 response: v2 yelp_id = 'grill-em-all-los-angeles'
    end
  end

  def self.scroll_through_trucks(city, state)
    all_trucks = []
    all_results = {}
    page = 1;

    result = food_trucks_in_city(city, state, "truck", V2_MAX_RADIUS_FILTER, page)
    all_results["page-#{page}"] = result
    return all_trucks if result.nil?

    all_trucks.push *result['businesses']

    total_results = result['total'] || 0
    puts "total_results: #{total_results}"

    total_pages = 1 + (total_results / V2_MAX_RESULTS_LIMIT)
    puts "total_pages: #{total_pages}"
    while total_pages > page and 1001 > all_trucks.size
      page += 1
      result = food_trucks_in_city(city, state, "truck", V2_MAX_RADIUS_FILTER, page)
      all_results["page-#{page}"] = result
      all_trucks.push *result['businesses']
      puts "#{result['total']} - #{all_trucks.size}"
    end
    all_trucks
  end

  def self.food_trucks_in_city(city, state, term="truck", radius=V2_MAX_RADIUS_FILTER, page=1)
    offset = V2_MAX_RESULTS_LIMIT*(page-1) # 1 + this ?
    query = {
      term: term,
      categories: ['streetvendors', 'foodstands'],
      city: city,
      state: state,
      radius_filter: radius,
      offset: offset,
      limit: V2_MAX_RESULTS_LIMIT
    }
    query = v2(query)
    request = Yelp::V2::Search::Request::Location.new(query)
    response = client.search(request)
  end

  def self.search_for_term(term, location, radius_filter=10000) # API v2 specifies radius_filter (not radius) and is in meters (max 40000)
    if location.geo_point.present?
      query = { term: term, radius_filter: radius_filter }.merge(location.geo_point)
      puts query
      query = v2(query)
      request = Yelp::V2::Search::Request::GeoPoint.new(query)
    elsif location.geo_boundary
      query = { term: term, radius_filter: radius_filter }.merge(location.geo_boundary)
      puts query
      query = v2(query)
      request = Yelp::V2::Search::Request::BoundingBox.new(query)
    else
      # query = { term: term, radius_filter: radius_filter, location: location.address_to_s }
      query = { term: term, radius_filter: radius_filter}.merge(location.mailing_address)
      puts query
      query = v2(query)
      request = Yelp::V2::Search::Request::Location.new(query)
    end
    response = client.search(request)
  end

  def self.search_for_category(category_array, location, radius_filter=10000)
    # be sureto use the category code (for example 'discgolf', not 'Disc Golf'):
    # category codes: http://www.yelp.com/developers/documentation/category_list
    if location.latitude
      query = { category: category_array, radius_filter: radius_filter }.merge(location.location.geo_point)
      query = v2(query)
      request = Yelp::V2::Search::Request::GeoPoint.new(query)
    elsif location.top_left_longitude
      query = { category: category_array, radius_filter: radius_filter }.merge(location.bounding_box)
      query = v2(query)
      request = Yelp::V2::Search::Request::BoundingBox.new(query)
    else
      # query = { category: category_array, radius_filter: radius_filter, location: location.address_to_s }
      query = { category: category_array, radius_filter: radius_filter}.merge(location.mailing_address)
      query = v2(query)
      request = Yelp::V2::Search::Request::Location.new(query)
    end
    response = client.search(request)
  end
  # /Yelp API

private

  def initialize() @webservice_client = Yelp::Client.new end
  def self.client() instance.webservice_client end

  def self.v1(query={}) SECRETS[:YELP][:V1].merge(query) end
  def self.v2(query={}) SECRETS[:YELP][:V2].merge(query) end


  def self.phone_number_10_digits(anything) # +++ TODO move this to Util class
    return nil if anything.nil?

    phone_number = "#{anything}".gsub(/[\(\)\-\s]/, '') # (345) 789-2234  -> 3457892234
    return nil if phone_number.nil?

    phone_number = nil unless phone_number.match(/^\d{10}$/) # make sure there are exactly 10 digits
    phone_number
  end

  def self.raise_if_response_is_invalid(response)
    raise "NilResponseFromYelp" if response.blank?
    raise "NoMessageFromYelp" if response['message'].blank?
    msg = response['message']
    code = msg['code']
    raise "#{msg['text']} Sent To yelp" unless code.zero?
    text = msg['text']
  end

  def self.biz_from_response(response)
    list = biz_list_from_response(response)
    puts "Got back #{list.size} bizes from Yelp. picking 1st one" if list.size > 1
    list.first
  end

  def self.biz_list_from_response(response)
    list = []
    list = response['businesses'] if response.present?
    list
  end

  def self.hood_from_response(response)
    list = hood_list_from_response(response)
    puts "Got back #{list.size} neighborhoods from Yelp. picking 1st one" if list.size > 1
    list.first
  end

  def self.hood_list_from_response(response)
    list = []
    list = response['neighborhoods'] if response.present?
    list
  end

  # keep V1 API private since it is depricated
  # -- Deprecated V1 Yelp Web Service API  - but still useful because it has phone number search and neighborhood lookup
  def self.v1_biz_for_phone_number(number)
    response = v1_search_for_phone_number(number)
    biz_list = biz_list_from_response(response)
    return nil if (biz_list.nil? or biz_list.size.zero?)
    biz_list.first
  end

  def self.v1_search_for_phone_number(number)
    phone_number = phone_number_10_digits(number)
    return nil if phone_number.nil?
    query = v1({phone_number: phone_number})
    request = Yelp::V1::Phone::Request::Number.new(query)
    response = client.search(request)
  end

  def self.v1_list_neighborhoods(location)
    # raise "InvalidLocation" if location is not valid
    if location.latitude
      query = v1(location.geo_point)
      request = Yelp::V1::Neighborhood::Request::GeoPoint.new(query)
    else
      query = v1(location.mailing_address)
      request = Yelp::V1::Neighborhood::Request::Location.new(query)
    end
    response = client.search(request)
  end

  def self.v1_search_for_term(term, location, radius=5) # API v1 specifies radius (not radius_filter) and is in miles (max 25)
    if location.geo_point.present?
      query = { term: term, radius: radius}.merge(location.geo_point)
      query = v1(query)
      request = Yelp::V1::Review::Request::GeoPoint.new(query)
    elsif location.geo_boundary
      query = { term: term, radius: radius }.merge(location.geo_boundary)
      query = v1(query)
      request = Yelp::V1::Review::Request::BoundingBox.new(query)
    else
      query = { term: term, radius: radius }.merge(location.mailing_address)
      query = v1(query)
      request = Yelp::V1::Review::Request::Location.new(query)
    end
    response = client.search(request)
  end

  def self.v1_search_for_category(category_array, location)
    if location.latitude
      query = { category: category_array }.merge(location.location.geo_point)
      query = v1(query)
      request = Yelp::V1::Review::Request::GeoPoint.new(query)
    elsif location.top_left_longitude
      query = { category: category_array }.merge(location.bounding_box)
      query = v1(query)
      request = Yelp::V1::Review::Request::BoundingBox.new(query)
    else
      query = { category: category_array }.merge(location.mailing_address)
      query = v1(query)
      request = Yelp::V1::Review::Request::Location.new(query)
    end
    response = client.search(request)
  end

end

# usage

# address search:
# location_zip = Location.new({ zip: '78759' })
# location_city = Location.new({ city: 'austin', state: 'tx' })
# location_street = Location.new({ address: '4501 Spicewood Spgs Rd', city: 'austin', state: 'tx' })
# location_geo = Location.new({ lat: 30.263779,  lng: -97.738165 })
# location_geo_box = Location.new({ ne_lat:30.27520 , ne_lng: -97.73208, sw_lat: 30.36614, sw_lng: -97.76957 })
# location_not_in_box = Location.new({ ne_lat: 30.27419, ne_lng: -97.73300, sw_lat: 30.25847, sw_lng: -97.75772})


# YelpService.search_for_term('mangia pizza', location_zip)
# YelpService.search_for_term('mangia pizza', location_city)
# YelpService.search_for_term('mangia pizza', location_street)
# YelpService.search_for_term('mangia pizza', location_geo)
# YelpService.search_for_term('mangia pizza', location_geo_box)
# YelpService.search_for_term('mangia pizza', location_not_in_box)

# # search for businesses via bounding box geo coords'
# request = Yelp::V2::Search::Request::BoundingBox.new(
# :term => “cream puffs”, :sw_latitude => 37.900000, :sw_longitude => -122.500000, :ne_latitude => 37.788022, :ne_longitude => -122.399797, :limit => 3, :consumer_key => ‘YOUR_CONSUMER_KEY’, :consumer_secret => ‘YOUR_CONSUMER_SECRET’, :token => ‘YOUR_TOKEN’, :token_secret => ‘YOUR_TOKEN_SECRET’)

# response = client.search(request)

# # search for businesses via lat/long geo point'
# request = Yelp::V2::Search::Request::GeoPoint.new(
# :term => “cream puffs”, :latitude => 37.788022, :longitude => -122.399797, :consumer_key => ‘YOUR_CONSUMER_KEY’, :consumer_secret => ‘YOUR_CONSUMER_SECRET’, :token => ‘YOUR_TOKEN’, :token_secret => ‘YOUR_TOKEN_SECRET’)

# response = client.search(request)

# # search for businesses via location (address, neighbourhood, city, state, zip, country, latitude, longitude)'
# request = Yelp::V2::Search::Request::Location.new(
# :term => “cream puffs”, :city => “San Francisco”, :consumer_key => ‘YOUR_CONSUMER_KEY’, :consumer_secret => ‘YOUR_CONSUMER_SECRET’, :token => ‘YOUR_TOKEN’, :token_secret => ‘YOUR_TOKEN_SECRET’)

# response = client.search(request)

# request = Yelp::V2::Search::Request::Location.new(
# :term => “german food”, :address => “Hayes”, :latitude => 37.77493, :longitude => -122.419415, :consumer_key => ‘YOUR_CONSUMER_KEY’, :consumer_secret => ‘YOUR_CONSUMER_SECRET’, :token => ‘YOUR_TOKEN’, :token_secret => ‘YOUR_TOKEN_SECRET’)

# response = client.search(request)

