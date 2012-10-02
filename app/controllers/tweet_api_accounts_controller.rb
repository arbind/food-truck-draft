class TweetApiAccountsController < BasicAuthProtectionController
  protect_from_forgery except: :sync


  def tweet_streams
    @tweet_streams = TweetApiAccount.streams
    @threads = TweetStreamService.instance.active_streams
    @threads_started = TweetStreamService.instance.start_listening

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: nil }
    end
  end

  def sync
    hash = JSON.parse(params[:tweet_api_account])
    status = sync(hash)
    respond_to do |format|
      format.html { render text: status} # index.html.erb
      format.json { render json: {status: status}.to_json }
    end
  end

  # GET /tweet_api_accounts
  # GET /tweet_api_accounts.json
  def index
    @tweet_api_accounts = TweetApiAccount.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tweet_api_accounts }
    end
  end

  def refresh
    @tweet_api_account = TweetApiAccount.find(params[:id])
    @tweet_api_account.remote_pull!
    respond_to do |format|
      format.html { redirect_to tweet_api_accounts_url }
      format.json { render json: {status: :ok } }
    end
  end

  def toggle_streamer
    @tweet_api_account = TweetApiAccount.find(params[:id])
    if @tweet_api_account.present?
      @tweet_api_account.is_tweet_streamer = ! @tweet_api_account.is_tweet_streamer
      @tweet_api_account.save!
    end
    respond_to do |format|
      format.html { redirect_to tweet_api_accounts_url }
      format.json { render json: {status: :ok } }
    end
  end

  # GET /tweet_api_accounts/1
  # GET /tweet_api_accounts/1.json
  def show
    @tweet_api_account = TweetApiAccount.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tweet_api_account }
    end
  end

  # GET /tweet_api_accounts/new
  # GET /tweet_api_accounts/new.json
  def new
    @tweet_api_account = TweetApiAccount.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tweet_api_account }
    end
  end

  # GET /tweet_api_accounts/1/edit
  def edit
    @tweet_api_account = TweetApiAccount.find(params[:id])
  end

  # POST /tweet_api_accounts
  # POST /tweet_api_accounts.json
  def create
    account = {
      twitter_id: params[:tweet_api_account][:twitter_id],
      screen_name: params[:tweet_api_account][:screen_name],
      oauth_config: params[:tweet_api_account].twitter_oauth_config
    }
    # client = Twitter::Client.new(account[oauth_config])
    # pull client.user(account[:twitter_username])
    # set twitter_id
    # set following_ids
    # set address based on location
    @tweet_api_account = TweetApiAccount.new(account)

    respond_to do |format|
      if @tweet_api_account.remote_pull!
        format.html { redirect_to @tweet_api_account, notice: 'Tweet stream account was successfully created.' }
        format.json { render json: @tweet_api_account, status: :created, location: @tweet_api_account }
      else
        format.html { render action: "new" }
        format.json { render json: @tweet_api_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tweet_api_accounts/1
  # PUT /tweet_api_accounts/1.json
  def update
    account = {
      twitter_id: params[:tweet_api_account][:twitter_id],
      screen_name: params[:tweet_api_account][:screen_name],
      oauth_config: params[:tweet_api_account].twitter_oauth_config
    }
    # client = Twitter::Client.new(account[oauth_config])
    # pull client.user(account[:twitter_username])
    # set twitter_id
    # set following_ids
    # set address based on location
    @tweet_api_account = TweetApiAccount.find(account)

    respond_to do |format|
      if @tweet_api_account.update_attributes(account)
        format.html { redirect_to @tweet_api_account, notice: 'Tweet stream account was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @tweet_api_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tweet_api_accounts/1
  # DELETE /tweet_api_accounts/1.json
  def destroy
    @tweet_api_account = TweetApiAccount.find(params[:id])
    @tweet_api_account.destroy

    respond_to do |format|
      format.html { redirect_to tweet_api_accounts_url }
      format.json { head :no_content }
    end
  end


  # def sync_tweet_api_account
  #   hash = JSON.parse(params[:tweet_api_account])
  #   clazz = TweetApiAccount
  #   status = sync(hash, clazz)
  #   respond_to do |format|
  #     format.html { render text: status} # index.html.erb
  #     format.json { render json: {status: status}.to_json }
  #   end
  # end

  def sync(hash)
    puts @ash

    # remove derived atts that need to be regenerated
    hash.delete('_id')
    hash.delete('created_at')
    hash.delete('updated_at')
    puts "============== #{hash['screen_name']}"
    puts hash

    (@account = TweetApiAccount.where(twitter_id: hash['twitter_id']).first) if hash['twitter_id'].present?
    @account ||= TweetApiAccount.where(screen_name: hash['screen_name']).first if hash['screen_name'].present?

    if @account.present?
      puts "Updating #{@account.screen_name} [#{@account._id}].."
      @account.update_attributes(hash)
    else
      puts "Creating #{@account.name}"
      @account = TweetApiAccount.create(hash)
    end

    @account.save if @account.present?

    if @account.present?
      status = 'ok' 
    else
      status = 'error'
    end

  end

end
