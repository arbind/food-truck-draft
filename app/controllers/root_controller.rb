class RootController < ApplicationController

  def index
    @look_for = params[:look_for]
    @place = params[:place]
    @radius = params[:radius] || 100 # miles

    @curent_user_place = 'la, ca' if request.location.coordinates.first.zero?
    @curent_user_place ||= request.location.address

    @coordinates = Geocoder.coordinates(@place) if @place.present?
      
    if @coordinates.nil? or @coordinates.first.zero?
      @place = @curent_user_place # no place specified, use visitors current location
      @coordinates = Geocoder.coordinates(@curent_user_place)
    end

    @address = Geocoder.address(@coordinates) if @coordinates
    @crafts = Craft.near(@coordinates, @radius) if @coordinates
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
    @crafts = Craft.near(request.location, 75)
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
