class CraftsController < ApplicationController
  # GET /crafts
  # GET /crafts.json
  def index
    @look_for = params[:q] || params[:look_for] || "food truck"
    @radius = params[:r] || params[:radius] || 100 # miles
    @page = params[:page] || 1

    # on click:
    # 1. get website YelpService.website_for_yelp_listing(q)
    # 2. load cratfs
    # 3. auto verify
    # 3. change/edit twitter handle/ facebook page / website url
    # 4. verify

    puts "=====================#{@geo_city}, #{@geo_state}, #{@look_for}, #{@page}"
    # @yelp_results = YelpService.food_trucks_in_city(@geo_city, @geo_state, @look_for, @page)
    @yelp_results = YelpService.food_trucks_in_city('santa monica', 'ca', @look_for, @page)
    puts @yelp_results
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: nil }
    end
 end


  # GET /crafts/find
  # GET /crafts/find.json
  def capture
    @url = Web.as_url(params[:url])
    @social_crafts = Web.web_craft_map(@url)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @craft }
    end
  end

  # GET /crafts/1
  # GET /crafts/1.json
  def show
    @craft = Craft.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @craft }
    end
  end

  # GET /crafts/new
  # GET /crafts/new.json
  def new
    # @craft = Craft.new

    # respond_to do |format|
    #   format.html # new.html.erb
    #   format.json { render json: @craft }
    # end
  end

  # GET /crafts/1/edit
  def edit
    @craft = Craft.find(params[:id])
  end

  # POST /crafts
  # POST /crafts.json
  def create
    @look_for = params[:look_for]
    @near = params[:near]

    if (@look_for.looks_like_url?)
      u = URI.parse(@look_for.downcase)
      u = URI.parse("http://#{@look_for.downcase}") if u.host.nil?
      capture_craft_url =@look_for if u.host
      @craft = Craft.materialize(capture_craft_url)
    else
      # see if we can parse the search term and find it
    end

    respond_to do |format|
      if @craft
        format.html { redirect_to @craft, notice: 'Craft was materialized.' }
        format.json { render json: @craft, status: :created, location: @craft }
      else
        format.html { render action: "new" }
        format.json { render json: @craft.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /crafts/1
  # PUT /crafts/1.json
  def update
    @craft = Craft.find(params[:id])

    respond_to do |format|
      if @craft.update_attributes(params[:craft])
        format.html { redirect_to @craft, notice: 'Craft was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @craft.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /crafts/1
  # DELETE /crafts/1.json
  def destroy
    @craft = Craft.find(params[:id])
    @craft.destroy

    respond_to do |format|
      format.html { redirect_to crafts_url }
      format.json { head :no_content }
    end
  end
end
