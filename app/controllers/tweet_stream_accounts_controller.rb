class TweetStreamAccountsController < ApplicationController
  # GET /tweet_stream_accounts
  # GET /tweet_stream_accounts.json
  def index
    @tweet_stream_accounts = TweetStreamAccount.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tweet_stream_accounts }
    end
  end

  def refresh
    @tweet_stream_account = TweetStreamAccount.find(params[:id])
    @tweet_stream_account.refresh
    respond_to do |format|
      format.html render action: :index
      format.json { render json: {status: :ok } }
    end
  end

  # GET /tweet_stream_accounts/1
  # GET /tweet_stream_accounts/1.json
  def show
    @tweet_stream_account = TweetStreamAccount.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tweet_stream_account }
    end
  end

  # GET /tweet_stream_accounts/new
  # GET /tweet_stream_accounts/new.json
  def new
    @tweet_stream_account = TweetStreamAccount.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tweet_stream_account }
    end
  end

  # GET /tweet_stream_accounts/1/edit
  def edit
    @tweet_stream_account = TweetStreamAccount.find(params[:id])
  end

  # POST /tweet_stream_accounts
  # POST /tweet_stream_accounts.json
  def create
    account = {
      twitter_id: params[:tweet_stream_account][:twitter_id],
      screen_name: params[:tweet_stream_account][:screen_name],
      oauth_config: params[:tweet_stream_account].twitter_oauth_config
    }
    # client = Twitter::Client.new(account[oauth_config])
    # pull client.user(account[:twitter_username])
    # set twitter_id
    # set following_ids
    # set address based on location
    @tweet_stream_account = TweetStreamAccount.new(account)

    respond_to do |format|
      if @tweet_stream_account.save
        format.html { redirect_to @tweet_stream_account, notice: 'Tweet stream account was successfully created.' }
        format.json { render json: @tweet_stream_account, status: :created, location: @tweet_stream_account }
      else
        format.html { render action: "new" }
        format.json { render json: @tweet_stream_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tweet_stream_accounts/1
  # PUT /tweet_stream_accounts/1.json
  def update
    account = {
      twitter_id: params[:tweet_stream_account][:twitter_id],
      screen_name: params[:tweet_stream_account][:screen_name],
      oauth_config: params[:tweet_stream_account].twitter_oauth_config
    }
    # client = Twitter::Client.new(account[oauth_config])
    # pull client.user(account[:twitter_username])
    # set twitter_id
    # set following_ids
    # set address based on location
    @tweet_stream_account = TweetStreamAccount.find(account)

    respond_to do |format|
      if @tweet_stream_account.update_attributes(account)
        format.html { redirect_to @tweet_stream_account, notice: 'Tweet stream account was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @tweet_stream_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tweet_stream_accounts/1
  # DELETE /tweet_stream_accounts/1.json
  def destroy
    @tweet_stream_account = TweetStreamAccount.find(params[:id])
    @tweet_stream_account.destroy

    respond_to do |format|
      format.html { redirect_to tweet_stream_accounts_url }
      format.json { head :no_content }
    end
  end
end
