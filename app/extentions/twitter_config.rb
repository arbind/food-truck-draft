class Hash
  def twitter_oauth_config
    cfg = {}
    cfg[:oauth_token] = (self[:oauth_token] || self['oauth_token']).squish if (self[:oauth_token] || self['oauth_token'])
    cfg[:oauth_token_secret] = (self[:oauth_token_secret] || self['oauth_token_secret']).squish if (self[:oauth_token_secret] || self['oauth_token_secret'])
    cfg[:consumer_key] = (self[:consumer_key] || self['consumer_key']).squish if (self[:consumer_key] || self['consumer_key'])
    cfg[:consumer_secret] = (self[:consumer_secret] || self['consumer_secret']).squish if (self[:consumer_secret] || self['consumer_secret'])
    cfg[:auth_method] = :oauth
    cfg
  end
end
