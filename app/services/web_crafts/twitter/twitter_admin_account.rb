class TwitterAdminAccount < TwitterApiAccount
  def self.beam_up(url='www.food-truck.me', path='twitter_api_accounts/sync_twitter_admin_account.json', use_ssl=false, cookies = {}, port=nil)
    TwitterAdminAccount.all.each do |s|
      s.beam_up(:twitter_admin_account, url, path, use_ssl, cookies, port)
    end
  end

end
