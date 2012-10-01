class TwitterApiAccountsController < ApplicationController
  protect_from_forgery :except => :sync

  def tweet_streams
    @tweet_streams = TweetStreamAccount.all
    @threads = TweetStreamService.instance.stream_threads
    @threads_started = TweetStreamService.instance.start_listening

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: nil }
    end
  end

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

private
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

end
