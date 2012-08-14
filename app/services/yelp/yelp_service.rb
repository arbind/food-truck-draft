class YelpService
  include Singleton
  attr_reader :yelp_client

  def self.biz(id_or_phone_number)
    phone_number = phone_number_10_digits(id_or_phone_number)
    if phone_number
      biz = biz_for_phone_number(phone_number) # returns nil if phone number is invalid and a yelp_id would be an invalid phone number
    else
      biz = biz_for_id(id_or_phone_number) # if phone number is invalid
    end
    biz
  end

  def self.biz_for_id(yelp_id)
    query = v2({yelp_business_id: yelp_id})
    request = Yelp::V2::Business::Request::Id.new(query)
    response = client.search(request)
  end

# response = client.search(request)

  def self.biz_for_phone_number(number)
    biz_list = biz_list_for_phone(number)
    return nil if (biz_list.nil? or biz_list.size.zero?)
    biz_list.first
  end

  def self.biz_list_for_phone(number)
    phone_number = phone_number_10_digits(number)
    return nil if phone_number.nil?
    query = v1({phone_number: phone_number})
    request = Yelp::V1::Phone::Request::Number.new(query)
    response = client.search(request)
    biz_list_from_response(response)
  end

  def self.biz_list_for_term(term, location)
    if location.latitude
      query = { term: term }.merge(location.location.geo_point)
      query = v1(query)
      request = Yelp::V1::Review::Request::GeoPoint.new(query)
    elsif location.top_left_longitude
      query = { term: term }.merge(location.bounding_box)
      query = v1(query)
      request = Yelp::V1::Review::Request::BoundingBox.new(query)
    else
      query = { term: term }.merge(location.mailing_address)
      query = v1(query)
      request = Yelp::V1::Review::Request::Location.new(query)
    end
    response = client.search(request)
    biz_list_from_response(response)
  end

  def self.biz_list_for_category(category_array, location)
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
    biz_list_from_response(response)
  end

  def self.neighborhood_list(location)
    # raise "InvalidLocation" if location is not valid
    if location.latitude
      query = v1(location.geo_point)
      request = Yelp::V1::Neighborhood::Request::GeoPoint.new(query)
    else
      query = v1(location.mailing_address)
      request = Yelp::V1::Neighborhood::Request::Location.new(query)
    end
    response = client.search(request)
    puts response
    hood_list_from_response(response)
  end


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



private

  def self.phone_number_10_digits(anything) # +++ TODO move this to Util class
    return nil if anything.nil?

    phone_number = "#{anything}".gsub(/[\(\)\-\s]/, '') # (345) 789-2234  -> 3457892234
    return nil if phone_number.nil?

    phone_number = nil unless phone_number.match(/^\d{10}$/) # make sure there are exactly 10 digits
    phone_number
  end


  def initialize()  @yelp_client = Yelp::Client.new end

  def self.client() YelpService.instance.yelp_client end

  def self.v1(query={}) SECRETS[:YELP][:V1].merge(query) end
  def self.v2(query={}) SECRETS[:YELP][:V2].merge(query) end

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
    begin
      raise_if_response_is_invalid(response)
      list = response['businesses']
    rescue Exception => e 
      list = []
    end
    list
  end

  def self.hood_from_response(response)
    list = hood_list_from_response(response)
    puts "Got back #{list.size} neighborhoods from Yelp. picking 1st one" if list.size > 1
    list.first
  end

  def self.hood_list_from_response(response)
    begin
      raise_if_response_is_invalid(response)
      list = response['neighborhoods']
    rescue Exception => e 
      list = []
    end
    list
  end

end