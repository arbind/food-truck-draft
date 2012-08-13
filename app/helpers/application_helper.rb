module ApplicationHelper

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
    STATES_FOR_CITY[kw]
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
    init_current_location
    init_query_location
  end

  def init_current_location
  end

  def init_query_location
  end

end
