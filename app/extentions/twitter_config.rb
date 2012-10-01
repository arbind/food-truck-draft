class Hash
  def twitter_config
    cfg = {}
    cfg[:oauth_token] = (self[:oauth_token] || self['oauth_token']) if (self[:oauth_token] || self['oauth_token'])
    cfg[:oauth_token_secret] = (self[:oauth_token_secret] || self['oauth_token_secret']) if (self[:oauth_token_secret] || self['oauth_token_secret'])
    cfg[:consumer_key] = (self[:consumer_key] || self['consumer_key']) if (self[:consumer_key] || self['consumer_key'])
    cfg[:consumer_secret] = (self[:consumer_secret] || self['consumer_secret']) if (self[:consumer_secret] || self['consumer_secret'])
  end
end
