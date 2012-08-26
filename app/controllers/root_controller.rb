class RootController < ApplicationController

  def index
    @look_for = params[:q] || params[:look_for]
    @radius = params[:r] || params[:radius] || 100 # miles

    puts "query_place: #{@query_place}"
    puts "query_coordinates: #{@query_coordinates}"
    puts "user_place: #{@user_place}"
    puts "user_coordinates: #{@user_coordinates}"
    puts "domain_place: #{@domain_place}"
    puts "domain_coordinates: #{@domain_coordinates}"
    puts "url_path_place: #{@url_path_place}"
    puts "url_path_coordinates: #{@url_path_coordinates}"
    puts "geo_place: #{@geo_place}"
    puts "geo_coordinates: #{@geo_coordinates}"

    @crafts = Craft.near(@geo_coordinates, @radius) if @geo_coordinates
    @crafts ||= Craft.near(@geo_place, @radius) if @geo_place
    if @look_for.present?
      @crafts = @crafts.where(search_tags: @look_for)  if @crafts.present?
      @crafts ||= Craft.where(search_tags: @look_for)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: nil }
    end
  end

  def route_subdomain
    @look_for = params[:q] || params[:look_for]
    @radius = params[:r] || params[:radius] || 100 # miles

    puts "query_place: #{@query_place}"
    puts "query_coordinates: #{@query_coordinates}"
    puts "user_place: #{@user_place}"
    puts "user_coordinates: #{@user_coordinates}"
    puts "domain_place: #{@domain_place}"
    puts "domain_coordinates: #{@domain_coordinates}"
    puts "url_path_place: #{@url_path_place}"
    puts "url_path_coordinates: #{@url_path_coordinates}"
    puts "geo_place: #{@geo_place}"
    puts "geo_coordinates: #{@geo_coordinates}"


    @crafts = Craft.near(@geo_coordinates, @radius) if @geo_coordinates
    @crafts ||= Craft.near(@geo_place, @radius) if @geo_place
    # view_path   = "root/#{@route_to}/index" if @route_to.present?
    view_path = "root/index"
    respond_to do |format|
      format.html { render view_path }
      format.json { render json: nil }
    end
  end

  def load_url
    @url = params[:url]
    if @url
      redirect_to @url 
    else
      redirect_to :index
    end
  end

end
