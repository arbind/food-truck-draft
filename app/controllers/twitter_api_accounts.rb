class TwitterApiAccountsController < ApplicationController
  protect_from_forgery :except => :sync

  def index
  end

  def tweet_streams
    @tweet_streams = TweetStreamAccount.all
    @threads = TweetStreamService.instance.stream_threads
    @threads_started = TweetStreamService.instance.start_listening

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: nil }
    end
  end

  # def tweet_streams
  #   @tweet_streams = CraftStream.all
  #   @threads = CraftStreamService.instance.threads
  #   @threads_started = CraftStreamService.instance.start    
  # end

  def sync_twitter_admin_account
    hash = JSON.parse(params[:twitter_admin_account])
    clazz = TwitterAdminAccount
    status = sync(hash, clazz)
    respond_to do |format|
      format.html { render text: status} # index.html.erb
      format.json { render json: {status: status}.to_json }
    end
  end

  def sync_tweet_stream_account
    hash = JSON.parse(params[:tweet_stream_account])
    clazz = TweetStreamAccount
    status = sync(hash, clazz)
    respond_to do |format|
      format.html { render text: status} # index.html.erb
      format.json { render json: {status: status}.to_json }
    end
  end

  def sync(hash, clazz)
    puts @ash

    # remove derived atts that need to be regenerated
    hash.delete('_id')
    hash.delete('created_at')
    hash.delete('updated_at')
    puts "============== #{hash['twitter_username']}"
    puts hash

    @account = clazz.where(twitter_username: hash['twitter_username']).first if hash['twitter_username'].present?
    (@account ||= clazz.where(twitter_id: hash['twitter_id']).first) if hash['twitter_id'].present?

    if @account.present?
      puts "Updating #{clazz.name} [#{@account._id}].."
      @account.update_attributes(hash)
    else
      puts "Creating #{clazz.name}"
      @account = clazz.create(hash)
    end

    @account.save if @account.present?

    if @account.present?
      status = 'ok' 
    else
      status = 'error'
    end

  end

  def show
    # @account = CraftStream.find(params[:id])

    # respond_to do |format|
    #   format.html # show.html.erb
    #   format.json { render json: @account }
    # end
  end

  # GET /tweet_streams/new
  # GET /tweet_streams/new.json
  def new
    # @account = CraftStream.new

    # respond_to do |format|
    #   format.html # new.html.erb
    #   format.json { render json: @account }
    # end
  end

  # GET /tweet_streams/1/edit
  def edit
    # @account = CraftStream.find(params[:id])
  end

  # POST /tweet_streams
  # POST /tweet_streams.json
  def create
    # @account = CraftStream.materialize(params)

    # respond_to do |format|
    #   if @account
    #     format.html { redirect_to @account, notice: 'Craft was materialized.' }
    #     format.json { render json: @account, status: :created, location: @account }
    #   else
    #     format.html { render action: "new" }
    #     format.json { render json: @account.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PUT /tweet_streams/1
  # PUT /tweet_streams/1.json
  def update
    # @account = CraftStream.find(params[:id])

    # respond_to do |format|
    #   if @account.update_attributes(params[:craft_stream])
    #     format.html { redirect_to @account, notice: 'Craft was successfully updated.' }
    #     format.json { head :no_content }
    #   else
    #     format.html { render action: "edit" }
    #     format.json { render json: @account.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # DELETE /tweet_streams/1
  # DELETE /tweet_streams/1.json
  def destroy
    # @account = CraftStream.find(params[:id])
    # @account.destroy

    # respond_to do |format|
    #   format.html { redirect_to tweet_streams_url }
    #   format.json { head :no_content }
    # end
  end
end
