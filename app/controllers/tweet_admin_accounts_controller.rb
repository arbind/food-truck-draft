class TweetAdminAccountsController < ApplicationController
  # GET /tweet_admin_accounts
  # GET /tweet_admin_accounts.json
  def index
    @tweet_admin_accounts = TweetAdminAccount.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tweet_admin_accounts }
    end
  end

  # GET /tweet_admin_accounts/1
  # GET /tweet_admin_accounts/1.json
  def show
    @tweet_admin_account = TweetAdminAccount.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tweet_admin_account }
    end
  end

  # GET /tweet_admin_accounts/new
  # GET /tweet_admin_accounts/new.json
  def new
    @tweet_admin_account = TweetAdminAccount.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tweet_admin_account }
    end
  end

  # GET /tweet_admin_accounts/1/edit
  def edit
    @tweet_admin_account = TweetAdminAccount.find(params[:id])
  end

  # POST /tweet_admin_accounts
  # POST /tweet_admin_accounts.json
  def create
    account = {
      twitter_id: params[:tweet_admin_account][:twitter_id],
      screen_name: params[:tweet_admin_account][:screen_name],
      oauth_config: params[:tweet_admin_account].twitter_oauth_config
    }
    # client = Twitter::Client.new(account[oauth_config])
    # pull client.user(account[:twitter_username])
    # set twitter_id
    # set following_ids
    # set address based on location
    @tweet_admin_account = TweetAdminAccount.new(account)

    respond_to do |format|
      if @tweet_admin_account.save
        format.html { redirect_to @tweet_admin_account, notice: 'Tweet admin account was successfully created.' }
        format.json { render json: @tweet_admin_account, status: :created, location: @tweet_admin_account }
      else
        format.html { render action: "new" }
        format.json { render json: @tweet_admin_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tweet_admin_accounts/1
  # PUT /tweet_admin_accounts/1.json
  def update
    account = {
      twitter_id: params[:tweet_admin_account][:twitter_id],
      screen_name: params[:tweet_admin_account][:screen_name],
      oauth_config: params[:tweet_admin_account].twitter_oauth_config
    }
    # client = Twitter::Client.new(account[oauth_config])
    # pull client.user(account[:twitter_username])
    # set twitter_id
    # set following_ids
    # set address based on location
    @tweet_admin_account = TweetAdminAccount.find(account)

    respond_to do |format|
      if @tweet_admin_account.update_attributes(account)
        format.html { redirect_to @tweet_admin_account, notice: 'Tweet admin account was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @tweet_admin_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tweet_admin_accounts/1
  # DELETE /tweet_admin_accounts/1.json
  def destroy
    @tweet_admin_account = TweetAdminAccount.find(params[:id])
    @tweet_admin_account.destroy

    respond_to do |format|
      format.html { redirect_to tweet_admin_accounts_url }
      format.json { head :no_content }
    end
  end
end
