class CraftsController < ApplicationController
  # GET /crafts
  # GET /crafts.json
  def index
    @crafts = Craft.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @crafts }
    end
  end

  # GET /crafts/find
  # GET /crafts/find.json
  def find
    @look_for = params[:look_for]

    if (Web.looks_like_url?(@look_for))
      u = URI.parse(@look_for.downcase)
      u = URI.parse("http://#{@look_for.downcase}") if u.host.nil?
      @capture_craft_url =@look_for if u.host
      session[u.host] = @capture_path
    else
      # see if we can parse the search term and find it
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @craft }
    end
  end

  # GET /crafts/find
  # GET /crafts/find.json
  def capture
    @url = Web.as_url(params[:url])
    @social_crafts = Web.social_crafts_for_website(@url)

    # @twitter_craft = @social_crafts[:twitter][:craft] if @social_crafts[:twitter].present
    # @facebook_craft = @social_crafts[facebook:][:craft] if @social_crafts[facebook:].present
    # @yelp_craft = @social_crafts[:yelp][:craft] if @social_crafts[:yelp].present
    # @flickr_craft = @social_crafts[flickr:][:craft] if @social_crafts[:flickr].present
    # @you_tube_craft = @social_crafts[:you_tube][:craft] if @social_crafts[:you_tube].present
    # @rss_craft = @social_crafts[:rss][:craft] if @social_crafts[:rss].present

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
    @craft = Craft.new(params[:craft])

    respond_to do |format|
      if @craft.save
        format.html { redirect_to @craft, notice: 'Craft was successfully created.' }
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
