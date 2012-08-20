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

    @social_pages = Web.social_pages_for_website(@url)

    @twitter_pages = @social_pages[:twitter_pages]
    if @twitter_pages.present?
      @twitter_handles = @twitter_pages.map{ |link| Web.username_from_twitter_page_url(link) }
      @primary_twitter_page =   @twitter_pages.first
      @primary_twitter_handle = @twitter_handles.first
    end

    @facebook_pages = @social_pages[:facebook_pages]
    if @facebook_pages.present?
      @facebook_handles = @facebook_pages.map{ |link| Web.pagename_from_facebook_page_url(link) }
      @primary_facebook_page = @facebook_pages.first
      @primary_facebook_handle = @facebook_handles.first
    end

    @flickr_pages = @social_pages[:flickr_pages]
    if @flickr_pages.present?
      @flickr_handles = @flickr_pages.map{ |link| Web.username_from_flickr_page_url(link) }
      @primary_flickr_page =   @flickr_pages.first
      @primary_flickr_handle = @flickr_handles.first
    end

    puts @yelp_listings
    @yelp_listings = @social_pages[:yelp_listings]
    if @yelp_listings.present?
      @yelp_handles = @yelp_listings.map{ |link| Web.username_from_yelp_listing_url(link) }
      puts @yelp_handles
      @primary_yelp_listing =   @yelp_listings.first
      puts @primary_yelp_listing
      @primary_yelp_handle = @yelp_handles.first
      puts @primary_yelp_handle
    end

    @rss_feeds = @social_pages[:rss_feeds]
    if @rss_feeds.present?
      @primary_rss_feed =   @rss_feeds.first
    end

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
