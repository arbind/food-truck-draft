class CraftStreamsController < ApplicationController
  protect_from_forgery :except => :sync

  def index
    @craft_streams = CraftStream.all
    @threads = stream_manager.stream_threads
    @threads_started = stream_manager.start

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: nil }
    end
  end

  # def tweet_streams
  #   @craft_streams = CraftStream.all
  #   @threads = CraftStreamService.instance.threads
  #   @threads_started = CraftStreamService.instance.start    
  # end

  def sync
    @hash = JSON.parse(params[:craft_stream])
    puts @hash

    # remove derived atts that need to be regenerated
    @hash.delete('_id')
    puts "============== #{@hash['twitter_username']}"
    puts @hash

    @craft_stream = CraftStream.where(twitter_username: @hash['twitter_username']).first if @hash['twitter_username'].present?
    (@craft_stream ||= CraftStream.where(twitter_id: @hash['twitter_id']).first) if @hash['twitter_id'].present?

    if @craft_stream.present?
      puts "Updating CraftStream [#{@craft_stream._id}].."
      @craft_stream.update_attributes(@hash)
    else
      puts "Creating CraftStream"
      @craft_stream = CraftStream.create(@hash)
    end

    @craft_stream.save if @craft_stream.present?

    if @craft_stream.present?
      status = 'ok' 
    else
      status = 'error'
    end

    respond_to do |format|
      format.html { render text: status} # index.html.erb
      format.json { render json: {status: status}.to_json }
    end

  end

  def show
    # @craft_stream = CraftStream.find(params[:id])

    # respond_to do |format|
    #   format.html # show.html.erb
    #   format.json { render json: @craft_stream }
    # end
  end

  # GET /craft_streams/new
  # GET /craft_streams/new.json
  def new
    # @craft_stream = CraftStream.new

    # respond_to do |format|
    #   format.html # new.html.erb
    #   format.json { render json: @craft_stream }
    # end
  end

  # GET /craft_streams/1/edit
  def edit
    # @craft_stream = CraftStream.find(params[:id])
  end

  # POST /craft_streams
  # POST /craft_streams.json
  def create
    # @craft_stream = CraftStream.materialize(params)

    # respond_to do |format|
    #   if @craft_stream
    #     format.html { redirect_to @craft_stream, notice: 'Craft was materialized.' }
    #     format.json { render json: @craft_stream, status: :created, location: @craft_stream }
    #   else
    #     format.html { render action: "new" }
    #     format.json { render json: @craft_stream.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PUT /craft_streams/1
  # PUT /craft_streams/1.json
  def update
    # @craft_stream = CraftStream.find(params[:id])

    # respond_to do |format|
    #   if @craft_stream.update_attributes(params[:craft_stream])
    #     format.html { redirect_to @craft_stream, notice: 'Craft was successfully updated.' }
    #     format.json { head :no_content }
    #   else
    #     format.html { render action: "edit" }
    #     format.json { render json: @craft_stream.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # DELETE /craft_streams/1
  # DELETE /craft_streams/1.json
  def destroy
    # @craft_stream = CraftStream.find(params[:id])
    # @craft_stream.destroy

    # respond_to do |format|
    #   format.html { redirect_to craft_streams_url }
    #   format.json { head :no_content }
    # end
  end
end
