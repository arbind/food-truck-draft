class ApplicationController < ActionController::Base
  include ActiveSupport::Inflector
  include ApplicationHelper
  attr_reader :subdomain, :target_interest

  protect_from_forgery

  # loads atts: @subdomain, @target_interest
  before_filter :init_keywords_for_subdomain
  before_filter :init_keywords_for_url_path 

  # determins @geo_place and @geo_coordinates, also finds @xxx_place/coordinates for @user_, @query_, @subdomain and @path
  before_filter :init_location

end
