class RootController < ApplicationController

  # @xxx_place and @xxx_coordinates are available for each of:
  # query, user, subdomain, url and geo
  # @geo_place and @geo_coordinates holds the highest priority (best guess of of which location to use) 

  def index
    @look_for = params[:q] || params[:look_for]
    @radius = params[:r] || params[:radius] || 100 # miles

    @crafts = Craft.near(@geo_coordinates, @radius).desc(:ranking_score).limit(10) if @geo_coordinates
    @crafts ||= Craft.near(@geo_place, @radius).desc(:ranking_score).limit(10) if @geo_place
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

    @crafts = Craft.near(@geo_coordinates, @radius).desc(:ranking_score).limit(10) if @geo_coordinates
    @crafts ||= Craft.near(@geo_place, @radius).desc(:ranking_score).limit(10) if @geo_place
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
