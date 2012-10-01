module ApplicationHelper
  def js_var(hash)
    @js_var ||= {}
    @js_var.merge!(hash)
  end

  def hide_middle(string_val)
    return "***" if string_val.size < 12
    "#{string_val[0..2]}...#{string_val[-3,3]}"
  end

  def href_for(path)
    "//#{request.host}:#{request.port}#{path}"
  end

  def subdomain_as_sym(host=request.host)
    return @subdomain if @subdomain

    tokens = host.split('.');
    return nil if 3 != tokens.size

    sub = tokens.first.downcase.underscore.to_sym
    return nil if :www === sub

    @subdomain = sub
  end

  # FOOD_TRUCK_NAME lookups
  def lookup_keyword_for_food_truck(nickname)
    sym = nickname.symbolize
    kw = FOOD_TRUCK_ALIASES[sym]
    return kw if kw
    kw = sym if FOOD_TRUCK_NAMES[sym]
    kw
  end    

  def lookup_food_truck(nickname)
    kw = lookup_keyword_for_food_truck(nickname)
    FOOD_TRUCK_NAMES[kw]
  end

  # CUISINE lookups
  def lookup_keyword_for_cuisine(nickname)
    sym = nickname.symbolize
    kw = CUISINE_ALIASES[sym]
    return kw if kw
    kw = sym if CUISINES[sym]
    kw
  end    

  def lookup_cuisine(nickname)
    kw = lookup_keyword_for_cuisine(nickname)
    CUISINES[kw]
  end    

  # MEAL lookups
  def lookup_keyword_for_meal(nickname)
    sym = nickname.symbolize
    kw = sym if MEALS[sym]
  end

  def lookup_meal(nickname)
    kw = lookup_keyword_for_meal(nickname)
    MEALS[kw]
  end    

  # STATE ABREVIATION lookups
  def lookup_keyword_for_state(nickname)
    sym = nickname.symbolize
    return sym if STATE[sym] # return the state abbreviation if it was passed in
    ST[sym] # lookup and return the state abbreviations if a state name was passed in
  end

  def lookup_state(nickname)
    kw = lookup_keyword_for_state(nickname)
    STATE[kw]
  end    

  def lookup_primary_location_for_state(nickname)
    location = {}
    location[:state_kw] =lookup_keyword_for_state(nickname)
    location[:state] = lookup_state(location[:state_kw])
    location
  end

  # METRO lookups
  def lookup_keyword_for_metro(city)
    sym = city.symbolize
    met = METRO_ALIASES[sym]
    met ||= sym
    METRO_AREAS[met] ? met : nil
  end

  def lookup_metro_area(city)
    met = lookup_keyword_for_metro(city)
    METRO_AREAS[met]
  end

  def lookup_primary_location_for_metro(city)
    location = {}

    location[:metro_kw] = lookup_keyword_for_metro(city)
    location[:metro] = metro =lookup_metro_area(location[:metro_kw])
    if metro
      location[:city_kw] = metro[:city_kw] || location[:metro_kw]
      location[:city] = lookup_city(location[:city_kw])

      location[:state_kw] = metro[:state_kw]
      location[:state] = lookup_state(location[:state_kw])
    end
    location
  end


  # CITY lookups
  def lookup_keyword_for_city(nickname)
    sym = nickname.symbolize
    kw = CITY_ALIASES[sym]
    return kw if kw
    kw = sym if STATES_FOR_CITY[sym]
    kw
  end

  def lookup_city(nickname)
    kw = lookup_keyword_for_city(nickname)
    kw = nickname if STATES_FOR_CITY[kw].nil?
    kw
  end

  def lookup_states_for_city(nickname)
    city_kw = lookup_keyword_for_city(nickname)
    STATES_FOR_CITY[city_kw]
  end

  def lookup_primary_location_for_city(nickname)
    location = {}

    location[:city_kw] = lookup_keyword_for_city(nickname)
    location[:city] = lookup_city(location[:city_kw])

    states = lookup_states_for_city(location[:city_kw])
    if states
      location[:state_kw] = states.first
      location[:state] = lookup_state(location[:state_kw])
    end

    metro_kw = lookup_keyword_for_metro(location[:city_kw])
    return location if metro_kw.nil?

    metro_area = lookup_metro_area(location[:city_kw])
    return location if metro_area.nil?

    if location[:state_kw] === metro_area[:state_kw]
      location[:metro_kw] = metro_kw 
      location[:metro] = lookup_metro_area(location[:metro_kw])
    end
    location
  end

  # COLLEGE_TOWN lookups
  def lookup_keyword_for_college(nickname)
    sym = nickname.symbolize
    kw = COLLEGE_ALIASES[sym]
    return kw if kw
    kw = sym if COLLEGE_TOWNS[sym]
    kw
  end    

  def lookup_college(nickname)
    kw = lookup_keyword_for_college(nickname)
    COLLEGE_TOWNS[kw]
  end

  def lookup_locations_for_college(nickname)
    college = lookup_college(nickname)
    locations = college[:locations] if college
  end

  def lookup_primary_location_for_college(nickname)
    location = {}

    college_locations = lookup_locations_for_college(nickname)
    return location if college_locations.nil?

    college_location = college_locations.first
    return location if college_location.nil?

    location[:city_kw] = college_location[:city_kw]    
    location[:state_kw] = college_location[:state_kw]

    location[:city]  = lookup_city (location[:city_kw])
    location[:state] = lookup_state(location[:state_kw])

    metro_kw = lookup_keyword_for_metro(location[:city_kw])
    return location if metro_kw.nil?

    metro_area = lookup_metro_area(location[:city_kw])
    return location if metro_area.nil?

    if location[:state_kw] === metro_area[:state_kw]
      location[:metro_kw] = metro_kw 
      location[:metro] = lookup_metro_area(location[:metro_kw])
    end
    location
  end

  # FESTIVAL_TOWN lookups [same pattern as COLLEGE_TOWN lookups]
  def lookup_keyword_for_festival(nickname)
    sym = nickname.symbolize
    kw = FESTIVAL_ALIASES[sym]
    return kw if kw
    kw = sym if FESTIVAL_TOWNS[sym]
    kw
  end    

  def lookup_festival(nickname)
    kw = lookup_keyword_for_festival(nickname)
    FESTIVAL_TOWNS[kw]
  end

  def lookup_locations_for_festival(nickname)
    festival = lookup_festival(nickname)
    locations = festival[:locations] if festival
  end

  def lookup_primary_location_for_festival(nickname)
    location = {}

    festival_locations = lookup_locations_for_festival(nickname)
    return location if festival_locations.nil?

    festival_location = festival_locations.first
    return location if festival_location.nil?

    location[:city_kw] = festival_location[:city_kw]
    location[:state_kw] = festival_location[:state_kw]

    location[:city]  = lookup_city(location[:city_kw])
    location[:state] = lookup_state(location[:state_kw])

    metro_kw = lookup_keyword_for_metro(location[:city_kw])
    return location if metro_kw.nil?

    metro_area = lookup_metro_area(location[:city_kw])
    return location if metro_area.nil?

    if location[:state_kw] === metro_area[:state_kw]
      location[:metro_kw] = metro_kw 
      location[:metro] = lookup_metro_area(location[:metro_kw]);
    end
    location
  end


  def init_keywords_for_subdomain
    @target_interest = {}
    @target_interest[:location] = {}

    @subdomain = subdomain_as_sym
    return nil if @subdomain.nil?
    
    # subdomain_route_def = SUBDOMAINS[@subdomain]
    # @highly_rated = subdomain_route_def[:highly_rated]

    @food_truck_kw = lookup_keyword_for_food_truck(@subdomain)
    if @food_truck_kw
      @target_interest[:food_truck_kw]  = @food_truck_kw
      @target_interest[:food_truck]     = lookup_food_truck(@food_truck_kw)
      @target_interest[:location]       = {}      
      return @subdomain
    end

    @college_kw = lookup_keyword_for_college(@subdomain)
    if @college_kw
      @target_interest[:college_kw] = @college_kw
      @target_interest[:college]    = lookup_college(@college_kw)
      @target_interest[:location]   = lookup_primary_location_for_college(@college_kw)
      # @city_kw, @state_kw = lookup_primary_college_location(@college_kw)
      # @metro_kw = lookup_primary_college_metro_keyword(@college_kw)
      return @subdomain
    end

    @fest_kw = lookup_keyword_for_festival(@subdomain)
    if @fest_kw
      @target_interest[:fest_kw]  = @fest_kw
      @target_interest[:fest]     = lookup_festival(@fest_kw)
      @target_interest[:location] = lookup_primary_location_for_festival(@fest_kw)
      # @city_kw, @state_kw = lookup_primary_festival_location(@fest_kw)
      # @metro_kw = lookup_primary_festival_metro_keyword(@fest_kw)
      return @subdomain
    end

    @cuisine_kw = lookup_keyword_for_cuisine(@subdomain)
    if @cuisine_kw
      @target_interest[:cuisine_kw] = @cuisine_kw
      @target_interest[:cuisine]    = lookup_cuisine(@cuisine_kw)
      @target_interest[:location]   = {}
      return @subdomain
    end

    @meal_kw = lookup_keyword_for_meal(@subdomain)
    if @meal_kw
      @target_interest[:meal_kw]  = @meal_kw
      @target_interest[:meal]     = lookup_meal(@meal_kw)
      @target_interest[:location] = {}
      return @subdomain
    end

    # assume @subdomain to be a location.

    @metro_kw = lookup_keyword_for_metro(@subdomain)
    if @metro_kw
      @target_interest[:area]     = :metro
      @target_interest[:location] = lookup_primary_location_for_metro(@metro_kw)
      return @subdomain
    end

    @city_kw = lookup_keyword_for_city(@subdomain)
    if @city_kw
      @target_interest[:area]     = :city
      @target_interest[:location] = lookup_primary_location_for_city(@city_kw)
      # @state_kw = lookup_primary_state_for_city(@city_kw)
      # @metro_kw = lookup_primary_city_metro_keyword(@city_kw)
      return @subdomain
    end

    @state_kw ||= lookup_keyword_for_state(@subdomain)
    if @state_kw
      @target_interest[:area]     = :state
      @target_interest[:location] = lookup_primary_location_for_state(@state_kw)
      return @subdomain
    end
  end

  def init_keywords_for_url_path
  end

  def init_location
    init_user_location
    init_query_location
    init_subdomain_location
    init_url_path_location

    if @query_place.present? and @query_coordinates.present?
      @geo_place = @query_place
      @geo_coordinates = @query_coordinates
      @geo_city = @query_city
      @geo_state = @query_state
    elsif @url_path_place.present? and @url_path_coordinates.present?
      @geo_place = @url_path_place
      @geo_coordinates = @url_path_coordinates
      @geo_city = @url_path_city
      @geo_state = @url_path_state
    elsif @subdomain_place.present? and @subdomain_coordinates.present?
      @geo_place = @subdomain_place
      @geo_coordinates = @subdomain_coordinates
      @geo_city = @subdomain_city
      @geo_state = @subdomain_state
    else
      @geo_place = @user_place
      @geo_coordinates = @user_coordinates
      @geo_city = @user_city
      @geo_state = @user_state
    end
    return true
  end

  def place_from_target_location
    return nil unless @target_interest.present?
    return nil unless @target_interest[:location].present?
    a = []
    a << @target_interest[:location][:city] if @target_interest[:location][:city].present?
    a << @target_interest[:location][:state] if @target_interest[:location][:state].present?
    if a.present?
      return a.join(', ')
    else
      return nil
    end
  end

  def init_subdomain_location
    @subdomain_place = place_from_target_location
    if @subdomain_place
      @subdomain_coordinates = Geocoder.coordinates(@subdomain_place)
      @subdomain_city, @subdomain_state = city_state_for_address(@subdomain_place)
    end
  end

  def init_url_path_location
    @url_path_place = place_from_target_location
    if @url_path_place
      @url_path_coordinates = Geocoder.coordinates(@url_path_place)
      @url_path_city, @url_path_state = city_state_for_address(@url_path_place)
    end
  end

  def init_user_location
    # see if current user coordinates are specified (overrides previous value in session)
    @user_coordinates = params[:uc] || params[:user_coordinates]
    if geo_coordinates_are_valid?(@user_coordinates)
      @user_place = Geocoder.address(@user_coordinates)
      if @user_place.present?
        @user_city, @user_state = city_state_for_address(@user_place)
        session[:user_place] = @user_place
        session[:user_coordinates] = @user_coordinates
        session[:user_city] = @user_city
        session[:user_state] = @user_state
        return true 
      end
    end

    # else see if user's place (address, landmark, college name, etc.) is specified (overrides previous value in session)
    @user_place = params[:up] || params[:user_place]
    if @user_place
      @user_coordinates = Geocoder.coordinates(@user_place)
      if geo_coordinates_are_valid?(@user_coordinates)
        @user_city, @user_state = city_state_for_address(@user_place)
        session[:user_place] = @user_place
        session[:user_coordinates] = @user_coordinates
        session[:user_city] = @user_city
        session[:user_state] = @user_state
        return true 
      end
    end

    # See if we already calculated the user's location and have it cached in the session
    @user_place = session[:user_place]
    @user_coordinates = session[:user_coordinates]
    @user_city = session[:user_city]
    @user_state = session[:user_state]
    return true if @user_place.present? and @user_coordinates.present?

    # else use the user's ip address to get location and cache it in the session
    if request.location
      @user_place = request.location.address
      @user_coordinates = request.location.coordinates
      if @user_place.present? and geo_coordinates_are_valid?(@user_coordinates)
        @user_city = request.location.city
        @user_state = request.location.state
        session[:user_place] = @user_place
        session[:user_coordinates] = @user_coordinates
        session[:user_city] = @user_city
        session[:user_state] = @user_state
        return true 
      end
    end

    #else default user's location to santa monica ;) and cache it in the session
    @user_place = 'Santa Monica, CA'
    @user_city = 'Santa Monica'
    @user_state = 'CA'
    @user_coordinates = [34.0194543, -118.4911912]
    session[:user_place] = @user_place
    session[:user_coordinates] = @user_coordinates
    session[:user_city] = @user_city
    session[:user_state] = @user_state
    return true
  end

  def init_query_location
    # see if coordinates are specified for where to search
    @query_coordinates = params[:qc] || params[:query_coordinates]
    if geo_coordinates_are_valid?(@query_coordinates)
      @query_place = Geocoder.address(@query_coordinates)
      @query_city, @query_state = city_state_for_address(@query_place)
      return true if @query_place.present?
    end

    # see if a place is specified for where to search
    @query_place = params[:qp] || params[:query_place]
    if @query_place
      @query_coordinates = Geocoder.coordinates(@query_place)
      if geo_coordinates_are_valid? (@query_coordinates)
        @query_city, @query_state = city_state_for_address(@query_place)
        return true if geo_coordinates_are_valid?(@query_coordinates)
      else
        @query_coordinates = nil
      end
    else
      @query_coordinates = nil
    end
  end

  def city_state_for_address(address)
    # find the first token that has only 2 chars and assume it is a state
    tokens = address.squish.split(',')
    return nil unless tokens.present?

    tokens.map!{|token| token.squish }
    state_idx = -1
    tokens.each_with_index {|token, idx| state_idx = idx if 2==token.size }

    city = state = nil
    case state_idx
    when -1 # no state was found, assume the last token is the city
      city = tokens[-1].titleize
    when 0 # first token seems to be the state
      state = tokens[0].upcase
    else # at least 2 tokens found, grab the state and assume the one before is a city 
      city = tokens[state_idx-1].titleize
      state = tokens[state_idx].upcase
    end
    return [city, state]
  end

  def geo_coordinates_are_valid?(coordinates)
    coordinates.present? and coordinates.kind_of?(Array) and 2 == coordinates.size  and -180 <= coordinates.first and coordinates.first <= 180 and -180 <= coordinates.second and coordinates.second <= 180
  end

  # Twitter Buttons
  def twitter_follow_button(username, show_screen_name = true, show_count=false, size=:large)
    button_html = ""
    button_html << "<a href='https://twitter.com/#{username}'"
    button_html << " data-show-count='#{show_count}'"
    button_html << " data-show-screen-name='#{show_screen_name}'"
    button_html << " data-size='large'" if :large == size
    button_html << " class='twitter-follow-button'>Follow @#{username}</a>"      
    button_html << "<script type='text/javascript'>"
    button_html << "  !function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src='//platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document,'script','twitter-wjs');"
    button_html << "</script>"
    button_html.html_safe
  end

#  follow button with iframe:
#  %iframe.tweet-follow-button{allowtransparency:"true", frameborder:0, scrolling:"no", src:"//platform.twitter.com/widgets/follow_button.html#align=right&button=grey&screen_name=#{tweeter.screen_name}&show_count=false&show_screen_name=false&lang=en"}

end
