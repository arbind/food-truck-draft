class TwitterAccount
  include Mongoid::Document
  field :kind, type: String
  field :username, type: String
  field :name, type: String
  field :description, type: String
  field :url, type: String
end
