class RootController < ApplicationController
  # @xxx_place and @xxx_coordinates are available for each of:
  # query, user, subdomain, url and geo
  # @geo_place and @geo_coordinates holds the highest priority (best guess of of which location to use) 

  def ping
    respond_to do |format|
      format.html { render text: :pong}
      format.json { render json: {ping: :pong} }
    end    
  end

  def index
    @look_for = params[:look_for] || params[:q]
    @radius = params[:radius] || params[:r] || 100 # miles
    @page = params[:page] || params[:p] || '1' # page
    @page = @page.to_i

    js_var(look_for: @look_for, radius: @radius, geo_place: @geo_place, geo_coordinates: @geo_coordinates)

    @crafts = Craft.near(@geo_coordinates, @radius).desc(:ranking_score) if @geo_coordinates
    @crafts ||= Craft.near(@geo_place, @radius).desc(:ranking_score) if @geo_place

    @total_crafts_count = @crafts.count
    limit = RESULTS_PER_PAGE
    skip = (@page-1) * RESULTS_PER_PAGE

    @crafts = @crafts.skip(skip).limit(limit).cache

    @total_pages = 1 + (@total_crafts_count/RESULTS_PER_PAGE).to_i
    js_var(total_crafts_count: @total_crafts_count, page: @page, total_pages: @total_pages)

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
