class TweetAdminAccount
  include Mongoid::Document
  field :twitter_id, :type => String
  field :twitter_username, :type => String
  field :oauth_token, :type => String
  field :oauth_token_secret, :type => String
  field :consumer_key, :type => String
  field :consumer_secret, :type => String
end
