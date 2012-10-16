class HoverCraftsController < BasicAuthProtectionController
  protect_from_forgery :except => :sync

  # ready_to_make
  # needs_tweet_stream
  # needs_yelp_craft
  # unknowns
  # approve_to_make

  # GET /crafts
  # GET /crafts.json
  def index
    @scope = params[:scope].symbolize if params[:scope].present?
    @scope ||= :approve_to_make

    @hover_crafts = HoverCraft.try(@scope).desc(:fit_score)
    @hover_crafts ||= HoverCraft.approve_to_make
    @hover_crafts.desc(:fit_score)
    # @hover_crafts = HoverCraft.ready_to_make.desc(:fit_score)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: nil }
    end
  end

  def sync
    @hash = JSON.parse(params[:hover_craft])
    puts @hash

    # remove derived atts that need to be regenerated
    @hash.delete('_id')
    @hash.delete('status')
    @hash.delete('craft_id')
    @hash.delete('yelp_craft_id')
    @hash.delete('twitter_craft_id')
    @hash.delete('facebook_craft_id')
    @hash.delete('created_at')
    @hash.delete('updated_at')

    puts "============== #{@hash['yelp_id']}"
    puts @hash

    @hover_craft = HoverCraft.where(yelp_id: @hash['yelp_id']).first if @hash['yelp_id'].present?
    (@hover_craft ||= HoverCraft.where(twitter_id: @hash['twitter_id']).first) if @hash['twitter_id'].present?
    (@hover_craft ||= HoverCraft.where(twitter_username: @hash['twitter_username']).first) if @hash['twitter_username'].present?
    (@hover_craft ||= HoverCraft.where(facebook_username: @hash['facebook_username']).first) if @hash['facebook_username'].present?

    if @hover_craft.present?
      puts "Updating HoverCraft [#{@hover_craft._id}].."
      @hover_craft.update_attributes(@hash)
    else
      puts "Creating HoverCraft"
      @hover_craft = HoverCraft.create(@hash)
    end

    @hover_craft.save if @hover_craft.present?

    if @hover_craft.present?
      status = 'ok' 
    else
      status = 'error'
    end

    respond_to do |format|
      format.html { render text: status} # index.html.erb
      format.json { render json: {status: status}.to_json }
    end

  end

  # GET /hover_crafts/1
  # GET /hover_crafts/1.json
  def show
    @hover_craft = HoverCraft.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @hover_craft }
    end
  end

  # GET /crafts/new
  # GET /crafts/new.json
  def new
    # @hover_craft = HoverCraft.new

    # respond_to do |format|
    #   format.html # new.html.erb
    #   format.json { render json: @hover_craft }
    # end
  end

  # GET /crafts/1/edit
  def edit
    @hover_craft = HoverCraft.find(params[:id])
  end

  # POST /hover_crafts
  # POST /hover_crafts.json
  def create
    @hover_craft = HoverCraft.materialize(params)

    respond_to do |format|
      if @hover_craft
        format.html { redirect_to @hover_craft, notice: 'Craft was materialized.' }
        format.json { render json: @hover_craft, status: :created, location: @hover_craft }
      else
        format.html { render action: "new" }
        format.json { render json: @hover_craft.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /crafts/1
  # PUT /crafts/1.json
  def update
    @hover_craft = HoverCraft.find(params[:id])

    respond_to do |format|
      if @hover_craft.update_attributes(params[:hover_craft])
        format.html { redirect_to @hover_craft, notice: 'Craft was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @hover_craft.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /crafts/1
  # DELETE /crafts/1.json
  def destroy
    @hover_craft = HoverCraft.find(params[:id])
    @hover_craft.destroy

    respond_to do |format|
      format.html { redirect_to hover_crafts_url }
      format.json { head :no_content }
    end
  end
end
