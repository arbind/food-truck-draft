class TweetStreamAccount < TwitterApiAccount
  #  twitter_password: 'foodTRUCK2012'
  
  def self.beam_up(url='www.food-truck.me', path='twitter_api_accounts/sync_tweet_stream_account.json', use_ssl=false, cookies = {}, port=nil)
    TweetStreamAccount.all.each do |s|
      s.beam_up(:tweet_stream_account ,url, path, use_ssl, cookies, port)
    end
  end
end
